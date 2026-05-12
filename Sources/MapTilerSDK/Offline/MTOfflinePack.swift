import Foundation

/// Represents a downloadable offline region.
public actor MTOfflinePack {
    /// The unique identifier of the pack.
    public let id: String
    /// The region definition of the pack.
    public let region: MTOfflineRegionDefinition
    /// The current state of the pack download.
    public private(set) var state: MTOfflinePackState = .pending {
        didSet {
            Task { [weak self] in
                await self?.syncMetadataToDisk()
            }
        }
    }
    /// The current progress of the pack download.
    public private(set) var progress: MTOfflinePackProgress = .init(totalResources: 0, downloadedResources: 0)

    /// The metadata object linking state and region.
    public private(set) var metadata: MTOfflinePackMetadata

    private let downloader: MTOfflineDownloader

    /// An optional delegate to receive download notifications.
    public func setDelegate(_ delegate: MTOfflineDownloadDelegate?) async {
        await downloader.setDelegate(delegate)
    }

    private var progressContinuations: [UUID: AsyncStream<MTOfflinePackProgress>.Continuation] = [:]

    /// Initializes a new pack to begin downloading.
    internal init(
        id: String,
        region: MTOfflineRegionDefinition,
        downloader: MTOfflineDownloader = MTOfflineDownloader()
    ) {
        self.id = id
        self.region = region
        self.downloader = downloader

        // Initialize new metadata
        self.metadata = MTOfflinePackMetadata(
            id: UUID(uuidString: id) ?? UUID(),
            region: region,
            state: .pending,
            size: 0,
            createdAt: Date()
        )
        // Initial state sync will happen because we set state below
        self.state = .pending
    }

    /// Initializes an existing pack from disk metadata.
    internal init(
        metadata: MTOfflinePackMetadata,
        downloader: MTOfflineDownloader = MTOfflineDownloader()
    ) {
        self.id = metadata.id.uuidString
        self.region = metadata.region
        self.downloader = downloader
        self.metadata = metadata

        // If a pack was "downloading" when the app was closed, it should be marked as paused or failed now.
        if metadata.state == .downloading {
            self.state = .paused
        } else {
            self.state = metadata.state
        }
    }

    /// Synchronizes the current in-memory metadata to disk.
    private func syncMetadataToDisk() async {
        // Update the struct before saving
        metadata.state = state

        do {
            try await MTOfflineStorage.saveMetadata(metadata)
        } catch {
            print("Failed to sync MTOfflinePack metadata to disk for \(id): \(error)")
        }
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
                state = .canceled
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
            state = .canceled
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

    private func buildTasks(from manifest: MTManifest) -> [any MTDownloadTask] {
        var tasks: [any MTDownloadTask] = []

        if let style = manifest.style {
            tasks.append(MTStyleDownloadTask(resource: style, packId: id))
        }

        let otherResources = manifest.tiles + manifest.glyphs + manifest.sprites
        tasks.append(contentsOf: otherResources.map { MTResourceDownloadTask(resource: $0) })

        return tasks
    }
}
