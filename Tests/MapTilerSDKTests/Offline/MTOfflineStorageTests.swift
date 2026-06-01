import Foundation
import Testing
@testable import MapTilerSDK

extension MTOfflineGlobalStorageTests {
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

    @Test("Concurrent atomic writes to the same file are thread-safe and don't corrupt")
    func testConcurrentAtomicWrites() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let destinationURL = tempDir.appendingPathComponent("concurrent.txt")
        
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<100 {
                group.addTask {
                    let data = "Concurrent write \(i)".data(using: .utf8)!
                    try? await MTOfflineStorage.write(data, to: destinationURL)
                }
            }
        }
        
        #expect(fileManager.fileExists(atPath: destinationURL.path))
        
        let finalData = try Data(contentsOf: destinationURL)
        let finalString = String(data: finalData, encoding: .utf8)!
        #expect(finalString.hasPrefix("Concurrent write "))
    }

    @Test("Atomic write fails gracefully on read-only directory")
    func testAtomicWriteToReadOnlyDirectory() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Make directory read-only
        try fileManager.setAttributes([.posixPermissions: 0o444], ofItemAtPath: tempDir.path)
        
        defer {
            // Restore permissions to allow cleanup
            try? fileManager.setAttributes([.posixPermissions: 0o777], ofItemAtPath: tempDir.path)
            try? fileManager.removeItem(at: tempDir)
        }
        
        let destinationURL = tempDir.appendingPathComponent("readonly.txt")
        let data = "Test".data(using: .utf8)!
        
        do {
            try await MTOfflineStorage.write(data, to: destinationURL)
            Issue.record("Write to read-only directory should have failed")
        } catch let error as MTOfflineStorageError {
            // Success: caught the expected enum type
            #expect(error.errorDescription?.contains("A file system error occurred") == true)
        } catch {
            Issue.record("Caught unexpected error type: \(error)")
        }
    }

    @Test("Calculate pack size tallies all valid files in a directory")
    func testCalculatePackSize() async throws {
        let packID = "test-size-\(UUID().uuidString)"
        let packURL = MTOfflineStoragePaths.packDirectory(for: packID)
        
        try fileManager.createDirectory(at: packURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: packURL) }
        
        let data1 = Data(repeating: 1, count: 1024) // 1 KB
        let data2 = Data(repeating: 2, count: 2048) // 2 KB
        
        try data1.write(to: packURL.appendingPathComponent("file1.dat"))
        try data2.write(to: packURL.appendingPathComponent("file2.dat"))
        
        let size = await MTOfflineStorage.calculatePackSize(for: packID)
        #expect(size == 3072, "Pack size should be the sum of all files (3 KB)")
    }

    @Test("List metadata discovers correctly saved packs")
    func testListMetadata() async throws {
        let packID1 = UUID().uuidString
        let packID2 = UUID().uuidString
        
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let region = MTOfflineRegionDefinition(
            bbox: bbox,
            minZoom: 0,
            maxZoom: 1,
            referenceStyle: .streets
        )
        
        let meta1 = MTOfflinePackMetadata(id: UUID(uuidString: packID1)!, region: region)
        let meta2 = MTOfflinePackMetadata(id: UUID(uuidString: packID2)!, region: region)
        
        // Save them to their respective pack directories
        try await MTOfflineStorage.saveMetadata(meta1)
        try await MTOfflineStorage.saveMetadata(meta2)
        
        defer {
            Task {
                try? await MTOfflineStorage.deletePack(for: packID1)
                try? await MTOfflineStorage.deletePack(for: packID2)
            }
        }
        
        let packs = try await MTOfflineStorage.listMetadata()
        let packIDs = packs.map { $0.id.uuidString }
        
        #expect(packIDs.contains(packID1))
        #expect(packIDs.contains(packID2))
    }
}
}
