import Foundation

/// Represents a downloadable offline region.
public actor MTOfflinePack {
    /// Creates a new offline pack and initializes its on-disk storage and metadata.
    ///
    /// - Parameters:
    ///   - region: The definition of the region to be downloaded.
    ///   - context: Optional custom data (e.g., JSON) to attach to the pack metadata.
    /// - Returns: A newly initialized `MTOfflinePack`.
    /// - Throws: An error if directory creation or metadata persistence fails.
    public static func createPack(
        region: MTOfflineRegionDefinition,
        context: Data? = nil
    ) async throws -> MTOfflinePack {
        let packId = UUID().uuidString
        let pack = MTOfflinePack(id: packId, region: region, context: context)

        // Ensure the pack directory and its initial subdirectories are created securely.
        let packURL = MTOfflineStoragePaths.packDirectory(for: packId)
        let tilesURL = packURL.appendingPathComponent("tiles", isDirectory: true)

        try await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            try MTOfflineStorage.secureCreateDirectory(
                at: MTOfflineStoragePaths.rootDirectory,
                fileManager: fileManager
            )
            try MTOfflineStorage.secureCreateDirectory(at: packURL, fileManager: fileManager)
            try MTOfflineStorage.secureCreateDirectory(at: tilesURL, fileManager: fileManager)
        }.value

        // Save initial metadata to disk
        try await MTOfflineStorage.saveMetadata(pack.metadata)

        return pack
    }

    /// Estimates the pack size for a given region definition.
    ///
    /// - Parameter region: The definition of the region to estimate.
    /// - Returns: An `MTPackStats` object containing the estimates.
    /// - Throws: An error if style fetching or parsing fails.
    public static func estimateSize(region: MTOfflineRegionDefinition) async throws -> MTPackStats {
        let estimator = MTOfflineEstimator()
        return try await estimator.estimatePack(region: region)
    }

    /// Retrieves all offline packs currently stored on disk.
    /// The packs are stably sorted by their creation date (oldest first).
    ///
    /// - Returns: An array of `MTOfflinePack` instances.
    public static func packs() async throws -> [MTOfflinePack] {
        let metadataList = try await MTOfflineStorage.listMetadata()
        let sortedMetadata = metadataList.sorted {
            if $0.createdAt == $1.createdAt {
                return $0.id.uuidString < $1.id.uuidString
            }
            return $0.createdAt < $1.createdAt
        }
        return sortedMetadata.map { MTOfflinePack(metadata: $0) }
    }

    /// Deletes all offline packs currently stored on disk.
    public static func removeAll() async throws {
        let allPacks = try await packs()
        for pack in allPacks {
            await pack.cancel()
        }

        try await Task.detached(priority: .userInitiated) {
            let rootDir = MTOfflineStoragePaths.rootDirectory
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: rootDir.path) {
                try fileManager.removeItem(at: rootDir)
            }
        }.value
    }

    /// The unique identifier of the pack.
    public nonisolated let id: String
    /// The region definition of the pack.
    public nonisolated let region: MTOfflineRegionDefinition
    /// The current progress of the pack download.
    public private(set) var progress: MTOfflinePackProgress = .init(totalResources: 0, downloadedResources: 0)

    /// The metadata object linking state and region.
    public private(set) var metadata: MTOfflinePackMetadata

    private let downloader: MTOfflineDownloader

    /// An optional delegate to receive download notifications.
    public weak var delegate: MTOfflineDownloadDelegate?

    /// If true, download progress updates will be reported to the delegate. Defaults to false.
    public var isProgressReportingEnabled: Bool = false

    private var lastProgressEventTime: Date = .distantPast

    /// The current state of the pack download.
    public private(set) var state: MTOfflinePackState = .pending {
        didSet {
            let newState = state
            let currentDelegate = delegate
            Task { [weak self, currentDelegate] in
                guard let self = self else { return }
                await self.syncMetadataToDisk()
                currentDelegate?.offlinePack(self.id, didChangeState: newState)
            }
        }
    }

    /// Initializes a new pack to begin downloading.
    internal init(
        id: String,
        region: MTOfflineRegionDefinition,
        context: Data? = nil,
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
            createdAt: Date(),
            context: context
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
        guard state != .canceled else { return }

        // Update the struct before saving
        metadata.state = state

        do {
            try await MTOfflineStorage.saveMetadata(metadata)
        } catch {
            print("Failed to sync MTOfflinePack metadata to disk for \(id): \(error)")
        }
    }

    private func updateProgress(completed: Int, skipped: Int) {
        progress.downloadedResources += (completed + skipped)

        guard isProgressReportingEnabled else { return }

        let now = Date()
        // Throttle progress events to at most 10 per second
        let shouldYield = now.timeIntervalSince(lastProgressEventTime) >= 0.1 ||
            progress.downloadedResources == progress.totalResources

        if shouldYield {
            lastProgressEventTime = now
            delegate?.offlinePack(id, didUpdateProgress: progress)
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
                if isProgressReportingEnabled {
                    delegate?.offlinePack(id, didUpdateProgress: progress)
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

    /// Deletes the offline pack.
    /// This stops any ongoing downloads and removes all associated files and metadata from disk.
    public func remove() async throws {
        // Stop any active downloads first.
        await cancel()

        // Update state to canceled before deleting files to prevent any pending tasks from recreating them
        state = .canceled

        // Remove the pack folder and all its contents from disk.
        try await MTOfflineStorage.deletePack(for: id)
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
