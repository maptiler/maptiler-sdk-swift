import Foundation
import Testing
@testable import MapTilerSDK

@Suite("MTOfflineStorage Tests")
struct MTOfflineStorageTests {
    
    let fileManager = FileManager.default
    
    @Test("Atomically write file successfully")
    func testSuccessfulWrite() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let destinationURL = tempDir.appendingPathComponent("final.txt")
        let data = "Test atomic write".data(using: .utf8)!
        
        try await MTOfflineStorage.write(data, to: destinationURL)
        
        #expect(fileManager.fileExists(atPath: destinationURL.path))
        
        let writtenData = try Data(contentsOf: destinationURL)
        #expect(writtenData == data)
    }
    
    @Test("Atomically replace existing file successfully")
    func testReplaceExistingFile() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let destinationURL = tempDir.appendingPathComponent("final.txt")
        let oldData = "Old data".data(using: .utf8)!
        try oldData.write(to: destinationURL)
        
        let newData = "New data".data(using: .utf8)!
        try await MTOfflineStorage.write(newData, to: destinationURL)
        
        let writtenData = try Data(contentsOf: destinationURL)
        #expect(writtenData == newData)
    }
    
    @Test("Interrupted move operation leaves no partial file")
    func testInterruptedMoveFile() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let destinationURL = tempDir.appendingPathComponent("final.txt")
        let nonExistentSource = tempDir.appendingPathComponent("missing.txt")
        
        do {
            try await MTOfflineStorage.moveFile(from: nonExistentSource, to: destinationURL)
            Issue.record("Move should have failed")
        } catch {
            #expect(error is MTOfflineStorageError)
        }
        
        // Verify no partial file exists at the final destination
        #expect(!fileManager.fileExists(atPath: destinationURL.path))
    }

    @Test("Test clean stale temp files")
    func testCleanStaleTempFiles() async throws {
        let tempDir = MTOfflineStoragePaths.tempDirectory
        
        if !fileManager.fileExists(atPath: tempDir.path) {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        let staleFileURL = tempDir.appendingPathComponent(UUID().uuidString)
        let staleData = "Stale temporary data".data(using: .utf8)!
        try staleData.write(to: staleFileURL)
        
        #expect(fileManager.fileExists(atPath: staleFileURL.path))
        
        await MTOfflineStorage.cleanStaleTempFiles()
        
        #expect(!fileManager.fileExists(atPath: staleFileURL.path), "Stale temporary file should be deleted")
        // The directory itself can remain
        #expect(fileManager.fileExists(atPath: tempDir.path))
    }

    @Test("Zero-byte files are identified as invalid and should be re-downloaded")
    func testZeroByteFileVerification() async throws {
        let tempFile = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        // Create an empty file (zero bytes)
        fileManager.createFile(atPath: tempFile.path, contents: Data(), attributes: nil)
        defer { try? fileManager.removeItem(at: tempFile) }
        
        let isVerified = MTOfflineStorage.isFileVerified(at: tempFile)
        #expect(!isVerified, "Zero-byte file should not be verified")
        
        // Create a non-empty file
        try "data".data(using: .utf8)?.write(to: tempFile)
        let isVerifiedValid = MTOfflineStorage.isFileVerified(at: tempFile)
        #expect(isVerifiedValid, "Non-empty file should be verified")
    }

    @Test("Stale temporary files in the pack directory are removed upon initialization")
    func testPackTempFileCleanup() async throws {
        let packID = "test-pack-\(UUID().uuidString)"
        let packURL = MTOfflineStoragePaths.packDirectory(for: packID)
        
        try fileManager.createDirectory(at: packURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: packURL) }
        
        // Create some "real" files
        let realFile = packURL.appendingPathComponent("style.json")
        try "{}".data(using: .utf8)?.write(to: realFile)
        
        // Create some "temp" files
        let dotFile = packURL.appendingPathComponent(".temp-file")
        try "temp".data(using: .utf8)?.write(to: dotFile)
        
        let uuidTempFile = packURL.appendingPathComponent(UUID().uuidString)
        try "temp".data(using: .utf8)?.write(to: uuidTempFile)
        
        // Verify they exist
        #expect(fileManager.fileExists(atPath: realFile.path))
        #expect(fileManager.fileExists(atPath: dotFile.path))
        #expect(fileManager.fileExists(atPath: uuidTempFile.path))
        
        // Run cleanup
        await MTOfflineStorage.cleanStaleTempFiles(for: packURL)
        
        // Verify results
        #expect(fileManager.fileExists(atPath: realFile.path), "Real files should remain")
        #expect(!fileManager.fileExists(atPath: dotFile.path), "Dot files should be removed")
        #expect(!fileManager.fileExists(atPath: uuidTempFile.path), "UUID-style temp files should be removed")
    }
    
    @Test("Downloader skips verified files")
    func testDownloaderSkipsVerifiedFiles() async throws {
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try "already here".data(using: .utf8)?.write(to: tempURL)
        defer { try? fileManager.removeItem(at: tempURL) }
        
        let downloader = MTOfflineDownloader()
        
        var executed = false
        let task = MockDownloadTask(id: "test", destinationURL: tempURL) {
            executed = true
        }
        
        try await downloader.download([task])
        
        #expect(!executed, "Task should have been skipped because file is already verified")
    }
}
