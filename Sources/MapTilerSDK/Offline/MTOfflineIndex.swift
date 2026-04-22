import Foundation

// Represents the download state of an individual offline asset.
internal enum MTOfflineAssetState: String, Codable, Equatable, Sendable {
    case pending
    case downloading
    case verified
    case failed
}

// The schema for the `index.json` file used to track asset downloads.
internal struct MTOfflineIndex: Codable, Equatable, Sendable {
    // The schema version. Reserved for future migrations. Starts at 1.
    internal var version: Int
    // Maps a unique asset ID (e.g., relative path) to its download state.
    internal var assets: [String: MTOfflineAssetState]

    internal init(version: Int = 1, assets: [String: MTOfflineAssetState] = [:]) {
        self.version = version
        self.assets = assets
    }
}

// A thread-safe manager for loading, updating, and saving the offline index.
internal actor MTOfflineIndexManager {
    private let fileURL: URL
    private var index: MTOfflineIndex

    // Initializes a new index manager that operates on the given file URL.
    internal init(fileURL: URL) {
        self.fileURL = fileURL
        self.index = MTOfflineIndex()
    }

    // Loads the index from disk and performs recovery.
    // If the file does not exist, it initializes an empty index.
    internal func load() async throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            self.index = MTOfflineIndex()
        } else {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()

            // --- Migration Placeholder ---
            // To handle future migrations, we could decode just the version first:
            // struct VersionOnly: Codable { let version: Int }
            // if let parsed = try? decoder.decode(VersionOnly.self, from: data),
            //    parsed.version < MTOfflineIndex().version {
            //     // Perform migration steps here...
            // }
            // -----------------------------

            self.index = try decoder.decode(MTOfflineIndex.self, from: data)
        }

        // Recover dangling states
        var stateChanged = false
        for (assetId, state) in index.assets where state == .downloading {
            index.assets[assetId] = .pending
            stateChanged = true
        }

        if stateChanged {
            try await save()
        }
    }

    // Atomically saves the current index state to disk.
    internal func save() async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(index)

        // Uses the atomic storage write method implemented previously
        try await MTOfflineStorage.write(data, to: fileURL)
    }

    // Updates the state of a specific asset.
    internal func updateState(for assetId: String, to state: MTOfflineAssetState) {
        index.assets[assetId] = state
    }

    // Retrieves the current state of a specific asset, if it exists.
    internal func state(for assetId: String) -> MTOfflineAssetState? {
        return index.assets[assetId]
    }

    // Retrieves a copy of the current index.
    internal var currentIndex: MTOfflineIndex {
        return index
    }
}
