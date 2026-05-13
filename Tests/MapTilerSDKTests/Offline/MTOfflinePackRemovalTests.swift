import Foundation
import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflinePack Removal Tests")
struct MTOfflinePackRemovalTests {
    
    let fileManager = FileManager.default
    
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
}
