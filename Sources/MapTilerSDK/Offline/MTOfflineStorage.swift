import Foundation

/// Errors that can occur during offline storage operations.
public enum MTOfflineStorageError: Error, LocalizedError {
    case writeFailed(Error)
    case moveFailed(Error)

    public var errorDescription: String? {
        switch self {
        case .writeFailed(let error):
            return "Failed to write to temporary location: \(error.localizedDescription)"
        case .moveFailed(let error):
            return "Failed to atomically move file to destination: \(error.localizedDescription)"
        }
    }
}

/// Provides atomic file writing capabilities to ensure robust storage.
internal enum MTOfflineStorage {

    // Atomically writes data to the specified destination URL.
    // The data is first written to a temporary location, then moved.
    internal static func write(_ data: Data, to destination: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            let fileManager = FileManager.default
            let tempDir = MTOfflineStoragePaths.tempDirectory

            if !fileManager.fileExists(atPath: tempDir.path) {
                try? fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            }

            let tempURL = tempDir.appendingPathComponent(UUID().uuidString)

            do {
                try data.write(to: tempURL)
            } catch {
                throw MTOfflineStorageError.writeFailed(error)
            }

            try moveAtomically(from: tempURL, to: destination, fileManager: fileManager)
        }.value
    }

    // Atomically moves an existing file to the specified destination URL.
    internal static func moveFile(from source: URL, to destination: URL) async throws {
        try await Task.detached(priority: .userInitiated) {
            try moveAtomically(from: source, to: destination, fileManager: FileManager.default)
        }.value
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

    // Cleans up any stale temporary files in the designated offline temporary directory
    // and within a specific pack directory if provided.
    internal static func cleanStaleTempFiles(for packURL: URL? = nil) async {
        await Task.detached(priority: .utility) {
            let fileManager = FileManager.default

            // 1. Clean the dedicated temp directory
            let tempDir = MTOfflineStoragePaths.tempDirectory
            if fileManager.fileExists(atPath: tempDir.path) {
                if let contents = try? fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil) {
                    for file in contents {
                        try? fileManager.removeItem(at: file)
                    }
                }
            }

            // 2. Clean temporary files in the pack directory if provided
            if let packURL = packURL, fileManager.fileExists(atPath: packURL.path) {
                let resourceKeys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
                guard let enumerator = fileManager.enumerator(
                    at: packURL,
                    includingPropertiesForKeys: resourceKeys,
                    options: [.skipsHiddenFiles]
                ) else { return }

                var toRemove: [URL] = []

                while let fileURL = enumerator.nextObject() as? URL {
                    guard let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
                        let isDirectory = resourceValues.isDirectory,
                        !isDirectory,
                        let name = resourceValues.name else { continue }

                    // Identify temp files: starting with dot, or looking like UUID/hex temp files
                    // Common atomic temp patterns: .something, UUID-style, or containing random strings
                    if name.hasPrefix(".") || isLikelyTempFile(name) {
                        toRemove.append(fileURL)
                    }
                }

                for fileURL in toRemove {
                    try? fileManager.removeItem(at: fileURL)
                }
            }
        }.value
    }

    private static func isLikelyTempFile(_ name: String) -> Bool {
        // Matches typical UUID patterns or common hex temp suffixes (e.g. .xxxxxx)
        let uuidPattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        if name.range(of: uuidPattern, options: .regularExpression) != nil {
            return true
        }

        // Also check for common atomic move temp patterns like "XXXXXX" (6 hex/chars) 
        // which some systems use, or very long random strings.
        if name.count > 30 && name.rangeOfCharacter(from: .alphanumerics.inverted) == nil {
            return true
        }

        return false
    }

    /// Verifies if a file exists and is valid (size > 0).
    internal static func isFileVerified(at url: URL) -> Bool {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return false }

        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize, fileSize > 0 {
                return true
            }
        } catch {
            return false
        }

        return false
    }

    private static func moveAtomically(from tempURL: URL, to destination: URL, fileManager: FileManager) throws {
        defer {
            // Clean up temporary file in case of failure or after successful move/replace
            try? fileManager.removeItem(at: tempURL)
        }

        do {
            let destinationDir = destination.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: destinationDir.path) {
                try fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true, attributes: nil)
            }

            if fileManager.fileExists(atPath: destination.path) {
                _ = try fileManager.replaceItemAt(
                    destination,
                    withItemAt: tempURL,
                    backupItemName: nil,
                    options: [.usingNewMetadataOnly]
                )
            } else {
                try fileManager.moveItem(at: tempURL, to: destination)
            }
        } catch {
            throw MTOfflineStorageError.moveFailed(error)
        }
    }
}
