import Foundation

/// Represents the current state of an offline pack download.
public enum MTOfflinePackState: String, Sendable, Codable, Equatable {
    /// The pack has been created but download has not started.
    case idle
    /// The pack is currently downloading.
    case downloading
    /// The pack download was paused.
    case paused
    /// The pack download was cancelled.
    case cancelled
    /// The pack download completed successfully.
    case completed
    /// The pack download failed.
    case failed
}

/// Represents a downloadable offline region.
public actor MTOfflinePack {
    /// The unique identifier of the pack.
    public let id: String
    /// The region definition of the pack.
    public let region: MTOfflineRegionDefinition
    /// The current state of the pack download.
    public private(set) var state: MTOfflinePackState = .idle
    /// The current progress of the pack download.
    public private(set) var progress: MTOfflinePackProgress = .init(totalResources: 0, downloadedResources: 0)

    private let downloader: MTOfflineDownloader

    private var progressContinuations: [UUID: AsyncStream<MTOfflinePackProgress>.Continuation] = [:]

    internal init(
        id: String,
        region: MTOfflineRegionDefinition,
        downloader: MTOfflineDownloader = MTOfflineDownloader()
    ) {
        self.id = id
        self.region = region
        self.downloader = downloader
    }

    /// A stream that yields progress updates as the pack downloads.
    public var progressStream: AsyncStream<MTOfflinePackProgress> {
        AsyncStream { continuation in
            let id = UUID()
            Task {
                await self.addProgressContinuation(id: id, continuation: continuation)
            }
            continuation.onTermination = { _ in
                Task {
                    await self.removeProgressContinuation(id: id)
                }
            }
        }
    }

    private func addProgressContinuation(id: UUID, continuation: AsyncStream<MTOfflinePackProgress>.Continuation) {
        progressContinuations[id] = continuation
        // Yield the current progress immediately to new listeners
        continuation.yield(progress)
    }

    private func removeProgressContinuation(id: UUID) {
        progressContinuations.removeValue(forKey: id)
    }

    private func updateProgress(completed: Int, skipped: Int) {
        progress.downloadedResources += (completed + skipped)
        for continuation in progressContinuations.values {
            continuation.yield(progress)
        }
    }

    /// Starts downloading the specified tasks for this pack.
    internal func startDownload(tasks: [any MTDownloadTask]) async throws {
        guard state != .downloading else { return }
        state = .downloading

        progress.totalResources = tasks.count
        progress.downloadedResources = 0

        let packURL = MTOfflineStoragePaths.packDirectory(for: id)

        do {
            try await downloader.download(tasks, packURL: packURL) { [weak self] completed, skipped in
                Task { [weak self] in
                    await self?.updateProgress(completed: completed, skipped: skipped)
                }
            }

            if !Task.isCancelled && state != .paused {
                state = .completed
                // Ensure UI sees 100% on completion
                progress.downloadedResources = progress.totalResources
                for continuation in progressContinuations.values {
                    continuation.yield(progress)
                }
            }
        } catch is CancellationError {
            if state != .paused {
                state = .cancelled
            }
            throw CancellationError()
        } catch {
            state = .failed
            throw error
        }
    }

    /// Starts downloading the pack using the provided manifest.
    internal func startDownload(manifest: MTManifest) async throws {
        try await MTOfflineStorage.saveManifest(manifest, for: id)
        let tasks = buildTasks(from: manifest)
        try await startDownload(tasks: tasks)
    }

    /// Resumes a previously paused or failed download.
    public func resume() async throws {
        let manifest = try MTOfflineStorage.loadManifest(for: id)
        let tasks = buildTasks(from: manifest)
        try await startDownload(tasks: tasks)
    }

    /// Cancels the ongoing download of the entire pack.
    public func cancel() async {
        if state == .downloading {
            state = .cancelled
            await downloader.cancel()
        }
    }

    /// Pauses the ongoing download of the entire pack.
    public func pause() async {
        if state == .downloading {
            state = .paused
            await downloader.cancel()
        }
    }

    /// Cancels the download of a specific asset within the pack.
    public func cancelAsset(id: String) async {
        await downloader.cancelAsset(id: id)
    }

    private func buildTasks(from manifest: MTManifest) -> [MTResourceDownloadTask] {
        var resources: [MTMapResource] = []
        if let style = manifest.style { resources.append(style) }
        resources.append(contentsOf: manifest.tiles)
        resources.append(contentsOf: manifest.glyphs)
        resources.append(contentsOf: manifest.sprites)

        return resources.map { MTResourceDownloadTask(resource: $0) }
    }
}
