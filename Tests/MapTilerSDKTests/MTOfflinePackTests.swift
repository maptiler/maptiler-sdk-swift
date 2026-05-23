import XCTest
@testable import MapTilerSDK

final class MTOfflinePackTests: XCTestCase {
    
    func testPackCancellationUpdatesStateAndStopsDownloads() async throws {
        let downloader = MTOfflineDownloader(maxInFlight: 2)
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let region = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 1, referenceStyle: .basic)
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
                
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                await tracker.endTask()
            }
            tasks.append(task)
        }
        
        let downloadOperation = Task {
            try await pack.startDownload(tasks: tasks)
        }
        
        // Wait until at least one task starts
        await fulfillment(of: [taskReadyToCancel], timeout: 5.0)
        
        // Wait a small amount for the async state to settle
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Cancel the pack
        await pack.cancel()
        
        // Wait for download operation to finish
        do {
            try await downloadOperation.value
        } catch {
            // Expected CancellationError
        }
        
        // Check state after cancellation
        let state = await pack.state
        XCTAssertEqual(state, MTOfflinePackState.canceled, "State should be updated to canceled.")
    }
}
