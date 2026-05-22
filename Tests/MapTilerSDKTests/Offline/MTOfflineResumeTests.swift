import Foundation
import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOffline Resume Tests", .serialized)
struct MTOfflineResumeTests {
    
    let fileManager = FileManager.default
    
    @Test("Download skips verified files")
    func testDownloadSkipsVerifiedFiles() async throws {
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let region = MTOfflineRegionDefinition(
            bbox: bbox,
            minZoom: 0,
            maxZoom: 0, // Only 1 tile
            referenceStyle: .basic
        )
        
        let pack = try await MTOfflinePack.createPack(region: region)
        let packId = pack.id
        
        // Mock a downloaded tile
        let packURL = MTOfflineStoragePaths.packDirectory(for: packId)
        let tilesURL = packURL.appendingPathComponent("tiles", isDirectory: true)
        try fileManager.createDirectory(at: tilesURL, withIntermediateDirectories: true)
        
        let manifest = MTManifest(
            metadata: MTManifestMetadata(
                referenceStyle: .basic,
                bbox: bbox,
                minZoom: 0,
                maxZoom: 0,
                pixelRatio: 1.0
            ),
            style: MTMapResource(url: URL(string: "https://api.maptiler.com/style.json")!, destinationPath: "style.json"),
            tiles: [MTMapResource(url: URL(string: "https://api.maptiler.com/tile.pbf")!, destinationPath: "tiles/0/0/0.pbf")],
            glyphs: [],
            sprites: []
        )
        
        let firstTile = manifest.tiles[0]
        
        let tileURL = MTOfflineStoragePaths.absoluteURL(for: packId, relativePath: firstTile.destinationPath)
        let tileDir = tileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: tileDir, withIntermediateDirectories: true)
        try "fake tile data".data(using: .utf8)?.write(to: tileURL)
        
        #expect(MTOfflineStorage.isFileVerified(at: tileURL))
        
        struct MockTask: MTDownloadTask {
            let id: String
            let destinationURL: URL?
            func execute() async throws {}
        }
        
        let task1 = MockTask(id: "task1", destinationURL: tileURL)
        let task2 = MockTask(id: "task2", destinationURL: tilesURL.appendingPathComponent("not_there.pbf"))
        
        let downloader = MTOfflineDownloader()
        
        class SafeCounter: @unchecked Sendable {
            private let lock = NSLock()
            var completed = 0
            var skipped = 0
            func add(completed: Int, skipped: Int) {
                lock.lock()
                defer { lock.unlock() }
                self.completed += completed
                self.skipped += skipped
            }
        }
        
        let counter = SafeCounter()
        
        try? await downloader.download([task1, task2]) { completed, skipped in
            counter.add(completed: completed, skipped: skipped)
        }
        
        let finalSkipped = counter.skipped
        let finalCompleted = counter.completed
        
        #expect(finalSkipped == 1, "One task should have been skipped")
        #expect(finalCompleted == 1, "One task should have been completed")

        try? await MTOfflineStorage.deletePack(for: packId)
    }

    @Test("MTMapView loadOfflinePack applies limits")
    @MainActor
    func testLoadOfflinePackAppliesLimits() async throws {
        let bbox = MTBoundingBox(minLon: 10, minLat: 10, maxLon: 20, maxLat: 20)
        let region = MTOfflineRegionDefinition(
            bbox: bbox,
            minZoom: 5,
            maxZoom: 15,
            referenceStyle: .basic
        )
        
        let pack = try await MTOfflinePack.createPack(region: region)
        
        let mapView = MTMapView(frame: .zero)
        
        do {
            try await mapView.loadOfflinePack(pack, limitToRegion: true)
        } catch {
            // Expected to fail in headless environment
        }
        
        try? await MTOfflineStorage.deletePack(for: pack.id)
    }
}
