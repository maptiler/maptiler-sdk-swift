import Foundation
import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflinePack Remove All Tests")
struct MTOfflinePackRemoveAllTests {
    
    let fileManager = FileManager.default
    
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
