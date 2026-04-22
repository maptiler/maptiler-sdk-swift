import Foundation
import Testing
@testable import MapTilerSDK

@Suite("MTOfflineIndexManager Tests")
struct MTOfflineIndexManagerTests {
    
    let fileManager = FileManager.default
    
    @Test("Test complete lifecycle: Create, Update, Serialize, Deserialize")
    func testIndexLifecycle() async throws {
        // 1. Setup temporary file URL
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let indexURL = tempDir.appendingPathComponent("index.json")
        
        // 2. Initialize manager and create a new index
        let manager = MTOfflineIndexManager(fileURL: indexURL)
        
        // Load should succeed and create an empty index in memory because file doesn't exist
        try await manager.load()
        
        let initialIndex = await manager.currentIndex
        #expect(initialIndex.version == 1, "Migration version should start at 1")
        #expect(initialIndex.assets.isEmpty, "Initial assets dictionary should be empty")
        
        // 3. Updating asset states
        let tileAssetId = "tiles/maptiler-planet/0/0/0.pbf"
        let styleAssetId = "style.json"
        
        await manager.updateState(for: tileAssetId, to: .pending)
        await manager.updateState(for: styleAssetId, to: .verified)
        
        let tileState = await manager.state(for: tileAssetId)
        let styleState = await manager.state(for: styleAssetId)
        
        #expect(tileState == .pending)
        #expect(styleState == .verified)
        
        // 4. Serializing to JSON (save) and verifying the structure
        try await manager.save()
        
        // Read raw JSON from disk
        let savedData = try Data(contentsOf: indexURL)
        let jsonObject = try JSONSerialization.jsonObject(with: savedData) as? [String: Any]
        
        #expect(jsonObject != nil)
        #expect(jsonObject?["version"] as? Int == 1, "Output JSON must contain the reserved version field")
        
        let assetsDict = jsonObject?["assets"] as? [String: String]
        #expect(assetsDict?[tileAssetId] == "pending")
        #expect(assetsDict?[styleAssetId] == "verified")
        
        // 5. Deserializing back to the Swift model
        let newManager = MTOfflineIndexManager(fileURL: indexURL)
        try await newManager.load()
        
        let reloadedIndex = await newManager.currentIndex
        #expect(reloadedIndex.version == 1)
        #expect(reloadedIndex.assets.count == 2)
        #expect(reloadedIndex.assets[tileAssetId] == .pending)
        #expect(reloadedIndex.assets[styleAssetId] == .verified)
    }

    @Test("Test recovery: dangling 'downloading' states are reset to 'pending' on load")
    func testRecoveryResetsDownloadingStates() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let indexURL = tempDir.appendingPathComponent("index.json")
        
        // Setup initial manager and index with dangling states
        let initialManager = MTOfflineIndexManager(fileURL: indexURL)
        try await initialManager.load()
        
        await initialManager.updateState(for: "asset_pending", to: .pending)
        await initialManager.updateState(for: "asset_downloading", to: .downloading)
        await initialManager.updateState(for: "asset_verified", to: .verified)
        await initialManager.updateState(for: "asset_failed", to: .failed)
        
        try await initialManager.save()
        
        // Load with a new manager to simulate startup recovery
        let newManager = MTOfflineIndexManager(fileURL: indexURL)
        try await newManager.load()
        
        let recoveredIndex = await newManager.currentIndex
        
        #expect(recoveredIndex.assets["asset_pending"] == .pending)
        #expect(recoveredIndex.assets["asset_downloading"] == .pending, "Downloading state should be recovered to pending")
        #expect(recoveredIndex.assets["asset_verified"] == .verified)
        #expect(recoveredIndex.assets["asset_failed"] == .failed)
        
        // Verify that the recovered state was saved to disk
        let diskData = try Data(contentsOf: indexURL)
        let jsonObject = try JSONSerialization.jsonObject(with: diskData) as? [String: Any]
        let assetsDict = jsonObject?["assets"] as? [String: String]
        #expect(assetsDict?["asset_downloading"] == "pending")
    }

    @Test("Test missing file handling: Initializes empty index")
    func testMissingFile() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let indexURL = tempDir.appendingPathComponent("missing_index.json")
        let manager = MTOfflineIndexManager(fileURL: indexURL)
        
        // This should not throw, it should initialize an empty index
        try await manager.load()
        let index = await manager.currentIndex
        #expect(index.version == 1)
        #expect(index.assets.isEmpty)
    }

    @Test("Test corrupt file handling: Throws error on malformed JSON")
    func testCorruptFile() async throws {
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }
        
        let indexURL = tempDir.appendingPathComponent("corrupt_index.json")
        let corruptData = "This is not valid JSON".data(using: .utf8)!
        try corruptData.write(to: indexURL)
        
        let manager = MTOfflineIndexManager(fileURL: indexURL)
        
        do {
            try await manager.load()
            Issue.record("Load should have failed with corrupt JSON")
        } catch {
            #expect(error is DecodingError)
        }
    }
}
