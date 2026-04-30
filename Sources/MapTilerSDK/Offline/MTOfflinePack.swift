import Foundation

/// Represents the current state of an offline pack download.
public enum MTOfflinePackState: String, Sendable, Codable, Equatable {
    /// The pack has been created but download has not started.
    case idle
    /// The pack is currently downloading.
    case downloading
    /// The pack download was paused (TBD).
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

    private let downloader: MTOfflineDownloader

    internal init(
        id: String,
        region: MTOfflineRegionDefinition,
        downloader: MTOfflineDownloader = MTOfflineDownloader()
    ) {
        self.id = id
        self.region = region
        self.downloader = downloader
    }

    /// Starts downloading the specified tasks for this pack.
    internal func startDownload(tasks: [any MTDownloadTask]) async throws {
        guard state != .downloading else { return }
        state = .downloading

        do {
            try await downloader.download(tasks)
            if !Task.isCancelled {
                state = .completed
            }
        } catch is CancellationError {
            state = .cancelled
            throw CancellationError()
        } catch {
            state = .failed
            throw error
        }
    }

    /// Cancels the ongoing download of the entire pack.
    public func cancel() async {
        if state == .downloading {
            state = .cancelled
            await downloader.cancel()
        }
    }

    /// Cancels the download of a specific asset within the pack.
    public func cancelAsset(id: String) async {
        await downloader.cancelAsset(id: id)
    }
}
