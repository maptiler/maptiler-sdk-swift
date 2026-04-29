import XCTest
@testable import MapTilerSDK

final class MTOfflinePackTests: XCTestCase {
    
    func testPackCancellationUpdatesStateAndStopsDownloads() async throws {
        let downloader = MTOfflineDownloader(maxInFlight: 2)
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let region = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 1, mapId: "basic")
        let pack = MTOfflinePack(id: "test-pack", region: region, downloader: downloader)
        
        actor CancellationTracker {
            var startedCount = 0
            var completedCount = 0
            
            func startTask() { startedCount += 1 }
            func endTask() { completedCount += 1 }
        }
        
        let tracker = CancellationTracker()
        let taskReadyToCancel = expectation(description: "Tasks started")
        
        var tasks: [MockDownloadTask] = []
        for i in 0..<5 {
            let task = MockDownloadTask(id: "task-\(i)") {
                await tracker.startTask()
                if i == 0 {
                    taskReadyToCancel.fulfill()
                }
                
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                await tracker.endTask()
            }
            tasks.append(task)
        }
        
        let downloadOperation = Task {
            try await pack.startDownload(tasks: tasks)
        }
        
        // Wait until at least one task starts
        await fulfillment(of: [taskReadyToCancel], timeout: 1.0)
        
        // Check state before cancellation
        var state = await pack.state
        XCTAssertEqual(state, MTOfflinePackState.downloading, "State should be downloading.")
        
        // Cancel the pack
        await pack.cancel()
        
        // Wait for download operation to finish
        do {
            try await downloadOperation.value
            XCTFail("Download operation should have thrown CancellationError.")
        } catch is CancellationError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Check state after cancellation
        state = await pack.state
        XCTAssertEqual(state, MTOfflinePackState.cancelled, "State should be updated to cancelled.")
        
        let started = await tracker.startedCount
        let completed = await tracker.completedCount
        
        XCTAssertLessThanOrEqual(started, 2, "Only up to maxInFlight tasks should have started.")
        XCTAssertEqual(completed, 0, "No tasks should have completed.")
    }
}
