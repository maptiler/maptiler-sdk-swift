import Foundation

/// Represents a downloadable offline region.
public actor MTOfflinePack {
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

    private var backgroundObserver: BackgroundObserver?

    /// If true, download progress updates will be reported to the delegate. Defaults to false.
    public var isProgressReportingEnabled: Bool = false

    private var lastProgressEventTime: Date = .distantPast
    private var isUsingBackground: Bool = false

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

    /// The date when the pack expires.
    public var expiresAt: Date {
        return metadata.expiresAt
    }

    /// Returns true if the pack has passed its expiration date.
    public var isExpired: Bool {
        return metadata.isExpired
    }

    /// Sets the delegate to receive download notifications.
    public func setDelegate(_ delegate: MTOfflineDownloadDelegate?) {
        self.delegate = delegate
    }

    /// Enables or disables progress reporting.
    public func setProgressReportingEnabled(_ isEnabled: Bool) {
        self.isProgressReportingEnabled = isEnabled
    }

    /// Initializes a new pack to begin downloading.
    public init(
        region: MTOfflineRegionDefinition,
        context: Data? = nil
    ) {
        let newId = UUID().uuidString
        self.id = newId
        self.region = region
        self.downloader = MTOfflineDownloader()

        // Initialize new metadata
        self.metadata = MTOfflinePackMetadata(
            id: UUID(uuidString: newId) ?? UUID(),
            region: region,
            state: .pending,
            size: 0,
            createdAt: Date(),
            context: context
        )
        // Initial state sync will happen because we set state below
        self.state = .pending
        Task { [weak self] in
            guard let self = self else { return }
            let observer = BackgroundObserver(pack: self, packId: newId)
            await self.setObserver(observer)
        }
    }

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
        Task { [weak self] in
            guard let self = self else { return }
            let observer = BackgroundObserver(pack: self, packId: id)
            await self.setObserver(observer)
        }
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
        if metadata.isExpired {
            self.state = .expired
        } else if metadata.state == .downloading {
            self.state = .paused
        } else {
            self.state = metadata.state
        }
        Task { [weak self] in
            guard let self = self else { return }
            let observer = BackgroundObserver(pack: self, packId: metadata.id.uuidString)
            await self.setObserver(observer)
        }
    }

    private func setObserver(_ observer: BackgroundObserver) {
        self.backgroundObserver = observer
    }

    deinit {
        // backgroundObserver will be released and its deinit will remove observers
    }

    internal func markBackgroundDownloadCompleted() {
        guard state == .downloading else { return }
        state = .completed
        progress.downloadedResources = progress.totalResources
        if isProgressReportingEnabled {
            delegate?.offlinePack(id, didUpdateProgress: progress)
        }
        Task { await syncMetadataToDisk() }
    }

    internal func markBackgroundDownloadFailed() {
        guard state == .downloading else { return }
        state = .failed
        Task { await syncMetadataToDisk() }
    }

    /// Synchronizes the current in-memory metadata to disk.
    private func syncMetadataToDisk() async {
        guard state != .canceled else { return }

        // Update the struct before saving
        metadata.state = state
        metadata.size = await MTOfflineStorage.calculatePackSize(for: id)

        do {
            try await MTOfflineStorage.saveMetadata(metadata)
        } catch {
            print("Failed to sync MTOfflinePack metadata to disk for \(id): \(error)")
        }
    }

    internal func updateProgress(completed: Int, skipped: Int) {
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

    internal func buildTasks(from manifest: MTManifest) -> [any MTDownloadTask] {
        var tasks: [any MTDownloadTask] = []

        if let style = manifest.style {
            tasks.append(MTStyleDownloadTask(resource: style, packId: id))
        }

        let otherResources = manifest.tiles + manifest.glyphs + manifest.sprites
        tasks.append(contentsOf: otherResources.map { MTResourceDownloadTask(resource: $0, packId: id) })

        return tasks
    }
}

// MARK: - Static Methods
extension MTOfflinePack {
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

    /// Cleans up packs that have been expired for longer than the grace period.
    /// This permanently deletes the packs and their files from the disk.
    public static func cleanupExpiredPacks() async throws {
        let allPacks = try await packs()
        let gracePeriod = MTOfflineConfiguration.shared.defaultGracePeriod

        for pack in allPacks where await pack.state == .expired {
            let expiresAt = await pack.expiresAt
            let timeSinceExpiration = Date().timeIntervalSince(expiresAt)
            if timeSinceExpiration > gracePeriod {
                try await pack.remove()
            }
        }
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
}

// MARK: - Download Actions
extension MTOfflinePack {
    /// Starts downloading the specified tasks for this pack.
    internal func startDownload(tasks: [any MTDownloadTask], useBackground: Bool = false) async throws {
        guard state != .downloading else { return }
        state = .downloading
        isUsingBackground = useBackground

        progress.totalResources = tasks.count
        progress.downloadedResources = 0

        let packURL = MTOfflineStoragePaths.packDirectory(for: id)

        if useBackground {
            try await MTOfflineBackgroundManager.shared.enqueue(tasks: tasks, for: id)
            // The background manager takes over downloading and reporting via notifications.
        } else {
            do {
                try await downloader.download(tasks, packURL: packURL) { [weak self] completed, skipped in
                    Task { [weak self] in
                        await self?.updateProgress(completed: completed, skipped: skipped)
                    }
                }

                if !Task.isCancelled && state != .paused && state != .canceled {
                    state = .completed
                    // Ensure UI sees 100% on completion
                    progress.downloadedResources = progress.totalResources
                    if isProgressReportingEnabled {
                        delegate?.offlinePack(id, didUpdateProgress: progress)
                    }
                    await syncMetadataToDisk()
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
    }

    /// Starts downloading the pack using the provided manifest.
    internal func startDownload(manifest: MTManifest, useBackground: Bool = false) async throws {
        try await MTOfflineStorage.saveManifest(manifest, for: id)
        let tasks = buildTasks(from: manifest)
        try await startDownload(tasks: tasks, useBackground: useBackground)
    }

    /// Starts the download process for this pack.
    /// This generates the necessary manifest based on the pack's region definition
    /// and then begins downloading all required resources.
    /// - Parameter useBackground: If true, the download will be enqueued in a background URLSession.
    public func download(useBackground: Bool = false) async throws {
        let planner = MTOfflinePlannerFactory.createPlanner()
        let manifest = try await planner.generateManifest(for: self.region)
        try await self.startDownload(manifest: manifest, useBackground: useBackground)
    }

    /// Resumes a previously paused or failed download.
    /// - Parameter useBackground: If true, the download will resume in a background URLSession.
    public func resume(useBackground: Bool = false) async throws {
        let manifest = try MTOfflineStorage.loadManifest(for: id)
        let tasks = buildTasks(from: manifest)
        try await startDownload(tasks: tasks, useBackground: useBackground)
    }

    /// Refreshes an expired pack, validating or updating its resources and resetting its expiration limit.
    /// - Parameter useBackground: If true, the download will be enqueued in a background URLSession.
    public func refresh(useBackground: Bool = false) async throws {
        // Reset the expiration date
        metadata.expiresAt = Date().addingTimeInterval(MTOfflineConfiguration.shared.defaultExpirationInterval)
        await syncMetadataToDisk()

        let planner = MTOfflinePlannerFactory.createPlanner()
        let manifest = try await planner.generateManifest(for: self.region)
        try await self.startDownload(manifest: manifest, useBackground: useBackground)
    }

    /// Cancels the ongoing download of the entire pack.
    public func cancel() async {
        if state == .downloading {
            state = .canceled
            if isUsingBackground {
                MTOfflineBackgroundManager.shared.cancelTasks(for: id)
            } else {
                await downloader.cancel()
            }
        }
    }

    /// Pauses the ongoing download of the entire pack.
    public func pause() async {
        if state == .downloading {
            state = .paused
            if isUsingBackground {
                MTOfflineBackgroundManager.shared.cancelTasks(for: id)
            } else {
                await downloader.cancel()
            }
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
}

private class BackgroundObserver: @unchecked Sendable {
    private var tokens: [Any] = []
    private weak var pack: MTOfflinePack?
    private let packId: String

    init(pack: MTOfflinePack, packId: String) {
        self.pack = pack
        self.packId = packId

        let center = NotificationCenter.default

        let progressToken = center.addObserver(
            forName: .mtOfflineBackgroundPackProgress,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self = self,
                let notifPackId = notification.userInfo?["packId"] as? String,
                notifPackId == self.packId else { return }
            Task { [weak self] in
                await self?.pack?.updateProgress(completed: 1, skipped: 0)
            }
        }

        let completedToken = center.addObserver(
            forName: .mtOfflineBackgroundPackCompleted,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self = self,
                let notifPackId = notification.userInfo?["packId"] as? String,
                notifPackId == self.packId else { return }
            Task { [weak self] in
                await self?.pack?.markBackgroundDownloadCompleted()
            }
        }

        let failedToken = center.addObserver(
            forName: .mtOfflineBackgroundPackFailed,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self = self,
                let notifPackId = notification.userInfo?["packId"] as? String,
                notifPackId == self.packId else { return }
            Task { [weak self] in
                await self?.pack?.markBackgroundDownloadFailed()
            }
        }

        self.tokens = [progressToken, completedToken, failedToken]
    }

    deinit {
        for token in tokens {
            NotificationCenter.default.removeObserver(token)
        }
    }
}
