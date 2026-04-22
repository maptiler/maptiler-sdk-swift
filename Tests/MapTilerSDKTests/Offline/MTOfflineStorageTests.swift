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
}
