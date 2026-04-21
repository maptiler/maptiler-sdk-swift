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
}
