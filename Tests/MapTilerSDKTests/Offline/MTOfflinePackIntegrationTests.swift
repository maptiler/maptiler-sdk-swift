import Foundation
import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflinePack Integration Tests", .serialized)
struct MTOfflinePackIntegrationTests {
    
    let fileManager = FileManager.default
    
    // MARK: - Creation Tests
    
    @Test("Pack creation initializes directory structure and metadata")
    func testCreatePack() async throws {
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let region = MTOfflineRegionDefinition(
            bbox: bbox,
            minZoom: 0,
            maxZoom: 10,
            mapId: "test-map",
            maxTileCount: 1000
        )
        
        let customContextString = "{\"myCustomKey\":\"myCustomValue\"}"
        let customContextData = customContextString.data(using: .utf8)
        
        let pack = try await MTOfflinePack.createPack(region: region, context: customContextData)
        let packId = pack.id
        
        defer {
            // Clean up the pack directory after the test
            let packURL = MTOfflineStoragePaths.packDirectory(for: packId)
            try? fileManager.removeItem(at: packURL)
        }
        
        // Check directory structure
        let packURL = MTOfflineStoragePaths.packDirectory(for: packId)
        let tilesURL = packURL.appendingPathComponent("tiles", isDirectory: true)
        let metadataURL = packURL.appendingPathComponent("metadata.json", isDirectory: false)
        
        #expect(fileManager.fileExists(atPath: packURL.path))
        #expect(fileManager.fileExists(atPath: tilesURL.path))
        #expect(fileManager.fileExists(atPath: metadataURL.path))
        
        // Verify metadata content
        let metadata = try MTOfflineStorage.loadMetadata(for: packId)
        #expect(metadata.id.uuidString == packId)
        #expect(metadata.region == region)
        #expect(metadata.region.maxTileCount == 1000)
        #expect(metadata.state == .pending)
        
        // Verify custom context
        #expect(metadata.context != nil)
        let loadedContextString = String(data: metadata.context!, encoding: .utf8)
        #expect(loadedContextString == customContextString)
    }
    
    // MARK: - Listing Tests
    
    @Test("List packs returns accurately and with stable sort")
    func testListPacks() async throws {
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let region = MTOfflineRegionDefinition(
            bbox: bbox,
            minZoom: 0,
            maxZoom: 10
        )
        
        // Create packs with delays to ensure different creation dates after ISO8601 truncation
        let pack1 = try await MTOfflinePack.createPack(region: region)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let pack2 = try await MTOfflinePack.createPack(region: region)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let pack3 = try await MTOfflinePack.createPack(region: region)
        
        let ids = [pack1.id, pack2.id, pack3.id]
        
        defer {
            for id in ids {
                let url = MTOfflineStoragePaths.packDirectory(for: id)
                try? fileManager.removeItem(at: url)
            }
        }
        
        let allPacks = try await MTOfflinePack.packs()
        
        // Filter to only the packs created in this test in case of leftovers
        let testPacks = allPacks.filter { ids.contains($0.id) }
        
        #expect(testPacks.count == 3)
        #expect(testPacks[0].id == pack1.id)
        #expect(testPacks[1].id == pack2.id)
        #expect(testPacks[2].id == pack3.id)
        
        // Verify accurate state and size for newly created pack
        #expect(await testPacks[0].state == .pending)
        #expect(await testPacks[0].metadata.size == 0)
    }
    
    @Test("List packs resolves stale downloading state and accurate size")
    func testAccurateStateAndSize() async throws {
        let packId = UUID().uuidString
        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1),
            minZoom: 0,
            maxZoom: 1
        )
        
        let packURL = MTOfflineStoragePaths.packDirectory(for: packId)
        try fileManager.createDirectory(at: packURL, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: packURL) }
        
        // Create a metadata file that simulates an interrupted download with an existing size
        let metadata = MTOfflinePackMetadata(
            id: UUID(uuidString: packId)!,
            region: region,
            state: .downloading, // should be paused upon load
            size: 5000,
            createdAt: Date()
        )
        try await MTOfflineStorage.saveMetadata(metadata)
        
        let allPacks = try await MTOfflinePack.packs()
        guard let listedPack = allPacks.first(where: { $0.id == packId }) else {
            Issue.record("Pack was not found in list")
            return
        }
        
        // Verify state is accurately transformed from downloading to paused
        #expect(await listedPack.state == .paused)
        
        // Verify size is accurately populated from metadata
        #expect(await listedPack.metadata.size == 5000)
    }
    
    // MARK: - Removal Tests
    
    @Test("Pack removal clears index and deletes files")
    func testRemovePack() async throws {
        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1),
            minZoom: 0,
            maxZoom: 1
        )
        
        let pack = try await MTOfflinePack.createPack(region: region)
        let packId = pack.id
        
        // Ensure pack directory and initial structure exists
        let packURL = MTOfflineStoragePaths.packDirectory(for: packId)
        #expect(fileManager.fileExists(atPath: packURL.path))
        
        // Simulate a populated index
        let indexURL = MTOfflineStoragePaths.indexURL(for: packId)
        let indexManager = MTOfflineIndexManager(fileURL: indexURL)
        await indexManager.updateState(for: "test_asset", to: .verified)
        try await indexManager.save()
        
        // Let file writes fully sync to disk before attempting removal
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Verify index was populated on disk
        let initialIndex = await indexManager.currentIndex
        #expect(initialIndex.assets.count == 1)
        #expect(fileManager.fileExists(atPath: indexURL.path))
        
        // Call remove
        try await pack.remove()
        
        // Let background file operations complete
        try await Task.sleep(nanoseconds: 200_000_000)
        
        // Verify state is set to canceled (to reflect it's no longer downloading/usable)
        #expect(await pack.state == .canceled)
        
        // We do not check indexManager.currentIndex because it's a separate instance.
        // Instead we check the disk.
        
        // Verify all files and pack directory are removed from disk
        #expect(!fileManager.fileExists(atPath: packURL.path))
        
        // Verify it no longer appears in the packs list
        let packs = try await MTOfflinePack.packs()
        #expect(!packs.contains { $0.id == packId })
    }
    
    // MARK: - Remove All Tests
    
    @Test("removeAll purges all packs from disk")
    func testRemoveAll() async throws {
        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1),
            minZoom: 0,
            maxZoom: 1
        )
        
        let _ = try await MTOfflinePack.createPack(region: region)
        let _ = try await MTOfflinePack.createPack(region: region)
        
        // Assert we have packs
        var packs = try await MTOfflinePack.packs()
        #expect(packs.count >= 2)
        
        // Call removeAll
        try await MTOfflinePack.removeAll()
        
        // Assert all packs are gone
        packs = try await MTOfflinePack.packs()
        #expect(packs.isEmpty)
        
        // Assert the root directory is actually removed
        let rootDir = MTOfflineStoragePaths.rootDirectory
        #expect(!fileManager.fileExists(atPath: rootDir.path))
    }
}
