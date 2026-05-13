import Foundation
import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflinePack Creation Tests")
struct MTOfflinePackCreationTests {
    
    let fileManager = FileManager.default
    
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
}
