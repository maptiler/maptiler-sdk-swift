import Foundation

/// Errors that can occur during offline storage operations.
public enum MTOfflineStorageError: Error, LocalizedError {
    case writeFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .writeFailed(let error):
            return "A file system error occurred: \(error.localizedDescription)"
        }
    }
}

/// Provides atomic file writing capabilities to ensure robust storage.
internal enum MTOfflineStorage {

    // Writes data to the specified destination URL atomically.
    internal static func write(_ data: Data, to destination: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            let destinationDir = destination.deletingLastPathComponent()

            try secureCreateDirectory(at: destinationDir, fileManager: fileManager)

            do {
                try data.write(to: destination, options: .atomic)
            } catch {
                throw MTOfflineStorageError.writeFailed(error)
            }
        }.value
    }

    // Moves an existing file to the specified destination URL.
    internal static func moveFile(from source: URL, to destination: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            let destinationDir = destination.deletingLastPathComponent()
            try secureCreateDirectory(at: destinationDir, fileManager: fileManager)

            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }

            do {
                try fileManager.moveItem(at: source, to: destination)
            } catch {
                throw MTOfflineStorageError.writeFailed(error)
            }
        }.value
    }

    // Helper to create a directory.
    internal static func secureCreateDirectory(at url: URL, fileManager: FileManager = .default) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)

            // Optional: Exclude from backup if it's in a location that gets backed up.
            // Since we are now in Caches, it's already excluded by the OS.
        }
    }

    // Saves the manifest to the pack directory.
    internal static func saveManifest(_ manifest: MTManifest, for packID: String) async throws {
        let data = try JSONEncoder().encode(manifest)
        let destination = MTOfflineStoragePaths.manifestURL(for: packID)
        try await write(data, to: destination)
    }

    // Loads the manifest from the pack directory.
    internal static func loadManifest(for packID: String) throws -> MTManifest {
        let fileURL = MTOfflineStoragePaths.manifestURL(for: packID)
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(MTManifest.self, from: data)
    }

    // MARK: - Metadata CRUD

    // Saves the metadata to the pack directory.
    internal static func saveMetadata(_ metadata: MTOfflinePackMetadata) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(metadata)
        let destination = MTOfflineStoragePaths.metadataURL(for: metadata.id.uuidString)
        try await write(data, to: destination)
    }

    // Loads the metadata from the pack directory.
    internal static func loadMetadata(for packID: String) throws -> MTOfflinePackMetadata {
        let fileURL = MTOfflineStoragePaths.metadataURL(for: packID)
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MTOfflinePackMetadata.self, from: data)
    }

    // Deletes the metadata and the entire pack directory.
    internal static func deletePack(for packID: String) async throws {
        try await Task.detached(priority: .userInitiated) {
            let directory = MTOfflineStoragePaths.packDirectory(for: packID)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: directory.path) {
                try fileManager.removeItem(at: directory)
            }
        }.value
    }

    // Lists all metadata files saved on disk.
    internal static func listMetadata() async throws -> [MTOfflinePackMetadata] {
        try await Task.detached(priority: .userInitiated) {
            let rootDir = MTOfflineStoragePaths.rootDirectory
            let fileManager = FileManager.default

            guard fileManager.fileExists(atPath: rootDir.path) else {
                return []
            }

            let contents = try fileManager.contentsOfDirectory(
                at: rootDir,
                includingPropertiesForKeys: [.isDirectoryKey]
            )

            var packs: [MTOfflinePackMetadata] = []
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            for folderURL in contents {
                guard (try? folderURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
                    continue
                }

                let metadataURL = folderURL.appendingPathComponent("metadata.json", isDirectory: false)
                if fileManager.fileExists(atPath: metadataURL.path), let data = try? Data(contentsOf: metadataURL) {
                    if let metadata = try? decoder.decode(MTOfflinePackMetadata.self, from: data) {
                        packs.append(metadata)
                    }
                }
            }

            return packs
        }.value
    }

    // Cleans up any stale temporary files.
    internal static func cleanStaleTempFiles(for packURL: URL? = nil) async {
        try? await Task.detached(priority: .background) {
            let fileManager = FileManager.default

            if let url = packURL {
                // Clean up specific pack directory (e.g. from interrupted downloads)
                let contents = (try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
                for item in contents {
                    let name = item.lastPathComponent
                    // Remove hidden files or UUID-style temp files
                    if name.hasPrefix(".") || UUID(uuidString: name) != nil {
                        try? fileManager.removeItem(at: item)
                    }
                }
            } else {
                // Clean up the global temp directory
                let tempDir = MTOfflineStoragePaths.tempDirectory
                if fileManager.fileExists(atPath: tempDir.path) {
                    let contents = (
                        try? fileManager.contentsOfDirectory(
                            at: tempDir,
                            includingPropertiesForKeys: nil
                        )
                    ) ?? []
                    for item in contents {
                        try? fileManager.removeItem(at: item)
                    }
                }
            }
        }.value
    }

    /// Calculates the total size of all files in the pack directory.
    internal static func calculatePackSize(for packID: String) async -> Int64 {
        let packURL = MTOfflineStoragePaths.packDirectory(for: packID)
        let fileManager = FileManager.default

        return await Task.detached(priority: .userInitiated) {
            var totalSize: Int64 = 0
            let enumerator = fileManager.enumerator(at: packURL, includingPropertiesForKeys: [.fileSizeKey])

            while let fileURL = enumerator?.nextObject() as? URL {
                if let resources = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                    let fileSize = resources.fileSize {
                    totalSize += Int64(fileSize)
                }
            }
            return totalSize
        }.value
    }

    /// Verifies if a file exists and is valid (size > 0).
    internal static func isFileVerified(at url: URL) -> Bool {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return false }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? Int64, fileSize > 0 {
                return true
            }
        } catch {
            return false
        }

        return false
    }
}
