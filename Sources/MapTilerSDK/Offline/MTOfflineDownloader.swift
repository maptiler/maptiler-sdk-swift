import Foundation

// A protocol representing an asset to be downloaded
internal protocol MTDownloadTask: Sendable {
    var id: String { get }
    var destinationURL: URL? { get }

    func execute() async throws
}

// An actor responsible for managing offline downloads
internal actor MTOfflineDownloader {
    internal let maxInFlight: Int
    private var isPackCancelled: Bool = false

    // Track active child tasks by their asset ID
    private var activeTasks: [String: Task<(String, Error?), Error>] = [:]

    // Initializes a new downloader.
    internal init(maxInFlight: Int = 5) {
        precondition(maxInFlight > 0, "maxInFlight must be greater than 0")
        self.maxInFlight = maxInFlight
    }

    internal func download(
        _ tasks: [any MTDownloadTask],
        packURL: URL? = nil,
        progressHandler: (@Sendable (_ completed: Int, _ skipped: Int) -> Void)? = nil
    ) async throws {
        await prepareForDownload(packURL: packURL)

        let (pendingTasks, skippedCount) = filterPendingTasks(tasks)
        progressHandler?(0, skippedCount)

        guard !pendingTasks.isEmpty else { return }

        try await withThrowingTaskGroup(of: (String, Error?).self) { group in
            var activeCount = 0
            var iterator = pendingTasks.makeIterator()

            fillInitialTasks(&iterator, activeCount: &activeCount, in: &group)
            try await processResults(
                &group,
                iterator: &iterator,
                activeCount: &activeCount,
                progressHandler: progressHandler
            )
        }

        if isPackCancelled || Task.isCancelled {
            throw CancellationError()
        }
    }

    private func prepareForDownload(packURL: URL?) async {
        isPackCancelled = false
        activeTasks.removeAll()

        if let packURL = packURL {
            await MTOfflineStorage.cleanStaleTempFiles(for: packURL)
        } else {
            await MTOfflineStorage.cleanStaleTempFiles()
        }
    }

    private func filterPendingTasks(_ tasks: [any MTDownloadTask]) -> (pending: [any MTDownloadTask], skipped: Int) {
        var pendingTasks: [any MTDownloadTask] = []
        var skippedCount = 0
        for task in tasks {
            if let destinationURL = task.destinationURL, MTOfflineStorage.isFileVerified(at: destinationURL) {
                skippedCount += 1
            } else {
                pendingTasks.append(task)
            }
        }
        return (pendingTasks, skippedCount)
    }

    private func fillInitialTasks(
        _ iterator: inout IndexingIterator<[any MTDownloadTask]>,
        activeCount: inout Int,
        in group: inout ThrowingTaskGroup<(String, Error?), Error>
    ) {
        while activeCount < maxInFlight, let nextTask = iterator.next() {
            guard !isPackCancelled else { break }
            activeCount += 1
            startChildTask(for: nextTask, in: &group)
        }
    }

    private func processResults(
        _ group: inout ThrowingTaskGroup<(String, Error?), Error>,
        iterator: inout IndexingIterator<[any MTDownloadTask]>,
        activeCount: inout Int,
        progressHandler: (@Sendable (_ completed: Int, _ skipped: Int) -> Void)?
    ) async throws {
        while let result = try await group.next() {
            activeTasks.removeValue(forKey: result.0)
            activeCount -= 1

            try handleDownloadResult(result, progressHandler: progressHandler)

            if isPackCancelled || Task.isCancelled {
                group.cancelAll()
                break
            }

            if let nextTask = iterator.next() {
                activeCount += 1
                startChildTask(for: nextTask, in: &group)
            }
        }
    }

    private func handleDownloadResult(
        _ result: (String, Error?),
        progressHandler: (@Sendable (_ completed: Int, _ skipped: Int) -> Void)?
    ) throws {
        if let error = result.1 {
            if !(error is CancellationError) {
                throw error
            }
        } else {
            progressHandler?(1, 0)
        }
    }

    private func startChildTask(
        for assetTask: any MTDownloadTask,
        in group: inout ThrowingTaskGroup<(String, Error?), Error>
    ) {
        let childTask = Task { () -> (String, Error?) in
            try Task.checkCancellation()
            do {
                try await assetTask.execute()
                return (assetTask.id, nil)
            } catch is CancellationError {
                return (assetTask.id, CancellationError())
            } catch {
                return (assetTask.id, error)
            }
        }

        activeTasks[assetTask.id] = childTask

        group.addTask {
            return try await childTask.value
        }
    }

    // Cancels the ongoing download process
    internal func cancel() {
        isPackCancelled = true
        for task in activeTasks.values {
            task.cancel()
        }
    }

    // Cancels a specific asset
    internal func cancelAsset(id: String) {
        if let task = activeTasks[id] {
            task.cancel()
            activeTasks.removeValue(forKey: id)
        }
    }
}
