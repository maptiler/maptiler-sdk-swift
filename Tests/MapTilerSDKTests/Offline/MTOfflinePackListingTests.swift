import Foundation
import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflinePack Listing Tests")
struct MTOfflinePackListingTests {
    
    let fileManager = FileManager.default
    
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
}
