import XCTest
@testable import MapTilerSDK

final class MTOfflinePackTests: XCTestCase {
    
    func testPackCancellationUpdatesStateAndStopsDownloads() async throws {
        let downloader = MTOfflineDownloader(maxInFlight: 2)
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let region = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 1, referenceStyle: .base)
        let pack = MTOfflinePack(id: "test-pack", region: region, downloader: downloader)

        actor TestTracker {
            var startedCount = 0
            var completedCount = 0
            private var continuation: CheckedContinuation<Void, Never>?

            func taskStarted() {
                startedCount += 1
                if startedCount == 2 {
                    continuation?.resume()
                    continuation = nil
                }
            }

            func taskCompleted() {
                completedCount += 1
            }

            func waitForTasksToStart() async {
                if startedCount >= 2 { return }
                await withCheckedContinuation { self.continuation = $0 }
            }
        }

        let tracker = TestTracker()

        let tasks = (0..<5).map { i in
            MockDownloadTask(id: "task-\(i)") {
                await tracker.taskStarted()
                
                // Block here until we signal from the test to simulate long running task
                // that can be cancelled.
                try await Task.sleep(nanoseconds: 1_000_000_000_000) // 1000s, effectively forever
                
                await tracker.taskCompleted()
            }
        }

        let downloadTask = Task {
            try await pack.startDownload(tasks: tasks)
        }

        // Wait for exactly 2 tasks to start (maxInFlight is 2)
        await tracker.waitForTasksToStart()

        // Now cancel
        await pack.cancel()

        // The download task should finish with CancellationError
        let result = await downloadTask.result
        switch result {
        case .failure(let error):
            XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
        case .success:
            XCTFail("Download task should have been cancelled")
        }

        let state = await pack.state
        XCTAssertEqual(state, .canceled)
        
        let completed = await tracker.completedCount
        XCTAssertEqual(completed, 0, "No tasks should have completed")
    }
}
