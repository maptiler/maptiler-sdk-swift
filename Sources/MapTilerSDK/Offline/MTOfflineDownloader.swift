import Foundation

// A protocol representing an asset to be downloaded
internal protocol MTDownloadTask: Sendable {
    var id: String { get }

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

    internal func download(_ tasks: [any MTDownloadTask]) async throws {
        isPackCancelled = false
        activeTasks.removeAll()

        try await withThrowingTaskGroup(of: (String, Error?).self) { group in
            var activeCount = 0
            var iterator = tasks.makeIterator()

            while activeCount < maxInFlight, let nextTask = iterator.next() {
                guard !isPackCancelled else { break }
                activeCount += 1
                startChildTask(for: nextTask, in: &group)
            }

            while let result = try await group.next() {
                activeTasks.removeValue(forKey: result.0)
                activeCount -= 1

                if let error = result.1 {
                    if error is CancellationError {
                        // Task was cancelled, depending on implementation we might break or continue
                        // For a pack cancellation, isPackCancelled will be true
                    } else {
                        // Throw the error to fail the entire group
                        throw error
                    }
                }

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

        if isPackCancelled || Task.isCancelled {
            throw CancellationError()
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
