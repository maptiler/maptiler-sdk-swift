import Foundation

// A protocol representing an asset to be downloaded
internal protocol MTDownloadTask: Sendable {
    var id: String { get }

    func execute() async throws
}

// An actor responsible for managing offline downloads
internal actor MTOfflineDownloader {
    internal let maxInFlight: Int
    private var downloadTask: Task<Void, Never>?

    // Initializes a new downloader.
    internal init(maxInFlight: Int = 5) {
        precondition(maxInFlight > 0, "maxInFlight must be greater than 0")
        self.maxInFlight = maxInFlight
    }

    internal func download(_ tasks: [any MTDownloadTask]) async throws {
        // Cancel any existing download task first
        cancel()

        let task = Task {
            await withTaskGroup(of: Void.self) { group in
                var activeCount = 0
                var iterator = tasks.makeIterator()

                while activeCount < maxInFlight, let nextTask = iterator.next() {
                    activeCount += 1
                    group.addTask {
                        guard !Task.isCancelled else { return }
                        do {
                            try await nextTask.execute()
                        } catch {
                            // Retry
                        }
                    }
                }

                while await group.next() != nil {
                    activeCount -= 1

                    if Task.isCancelled {
                        group.cancelAll()
                        break
                    }

                    if let nextTask = iterator.next() {
                        activeCount += 1
                        group.addTask {
                            guard !Task.isCancelled else { return }
                            do {
                                try await nextTask.execute()
                            } catch {
                                // Retry
                            }
                        }
                    }
                }
            }
        }

        self.downloadTask = task

        await task.value

        if task.isCancelled {
            throw CancellationError()
        }

        self.downloadTask = nil
    }

    // Cancels the ongoing download process
    func cancel() {
        downloadTask?.cancel()
        downloadTask = nil
    }
}
