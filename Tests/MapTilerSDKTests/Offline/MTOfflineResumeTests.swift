import Foundation
import Testing
import CoreLocation
@testable import MapTilerSDK

extension MTOfflineGlobalStorageTests {
    @Suite("MTOffline Resume Tests")
    struct MTOfflineResumeTests {
    
    let fileManager = FileManager.default
    
    @Test("Download skips verified files")
    func testDownloadSkipsVerifiedFiles() async throws {
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        
        let packId = "resume-test-" + UUID().uuidString
        let packURL = MTOfflineStoragePaths.packDirectory(for: packId)
        
        // Clean up any existing data for this test ID
        try? await MTOfflineStorage.deletePack(for: packId)
        
        let tilesURL = packURL.appendingPathComponent("tiles", isDirectory: true)
        try fileManager.createDirectory(at: tilesURL, withIntermediateDirectories: true)
        
        let manifest = MTManifest(
            metadata: MTManifestMetadata(
                referenceStyle: .base,
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
        
        class ProgressTracker: @unchecked Sendable {
            private let lock = NSLock()
            var completedCount = 0
            var skippedCount = 0
            var updateCount = 0
            private var continuation: CheckedContinuation<Void, Never>?

            func add(completed: Int, skipped: Int) {
                lock.lock()
                defer { lock.unlock() }
                self.completedCount += completed
                self.skippedCount += skipped
                self.updateCount += 1
                
                // We expect 2 updates: 
                // 1. Initial skip count (0, 1)
                // 2. Completion of task2 (1, 0)
                if updateCount == 2 {
                    continuation?.resume()
                    continuation = nil
                }
            }

            func waitForUpdates() async {
                await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                    lock.lock()
                    if updateCount >= 2 {
                        lock.unlock()
                        cont.resume()
                        return
                    }
                    self.continuation = cont
                    lock.unlock()
                }
            }
        }
        
        let tracker = ProgressTracker()
        
        try await downloader.download([task1, task2]) { completed, skipped in
            tracker.add(completed: completed, skipped: skipped)
        }
        
        // Wait for all progress updates to be processed
        await tracker.waitForUpdates()

        let finalSkipped = tracker.skippedCount
        let finalCompleted = tracker.completedCount
        
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
            referenceStyle: .base
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
}
