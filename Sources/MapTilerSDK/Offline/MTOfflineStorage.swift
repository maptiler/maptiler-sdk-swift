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
            let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)

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
