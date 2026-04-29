import XCTest
@testable import MapTilerSDK

final class MockDownloadTask: MTDownloadTask, @unchecked Sendable {
    let id: String
    private let executeBlock: () async throws -> Void
    
    init(id: String, executeBlock: @escaping () async throws -> Void) {
        self.id = id
        self.executeBlock = executeBlock
    }
    
    func execute() async throws {
        try await executeBlock()
    }
}

final class MTOfflineDownloaderTests: XCTestCase {
    
    func testConcurrencyLimitIsRespected() async throws {
        let maxInFlight = 3
        let totalTasks = 10
        let downloader = MTOfflineDownloader(maxInFlight: maxInFlight)
        
        // We use an actor to safely track concurrent execution count
        actor ConcurrencyTracker {
            var currentInFlight = 0
            var maxObservedInFlight = 0
            var completedCount = 0
            
            func startTask() {
                currentInFlight += 1
                if currentInFlight > maxObservedInFlight {
                    maxObservedInFlight = currentInFlight
                }
            }
            
            func endTask() {
                currentInFlight -= 1
                completedCount += 1
            }
        }
        
        let tracker = ConcurrencyTracker()
        
        var tasks: [MockDownloadTask] = []
        for i in 0..<totalTasks {
            let task = MockDownloadTask(id: "task-\(i)") {
                await tracker.startTask()
                // Simulate network delay
                try await Task.sleep(nanoseconds: 50_000_000) // 50ms
                await tracker.endTask()
            }
            tasks.append(task)
        }
        
        try await downloader.download(tasks)
        
        let maxObserved = await tracker.maxObservedInFlight
        let completed = await tracker.completedCount
        
        XCTAssertEqual(completed, totalTasks, "All tasks should have completed.")
        XCTAssertLessThanOrEqual(maxObserved, maxInFlight, "The concurrency limit should be strictly respected.")
        // Also check it actually hit the limit (or close to it) to ensure it wasn't strictly sequential
        XCTAssertGreaterThan(maxObserved, 1, "It should execute tasks concurrently.")
    }
    
    func testGracefulShutdownAndCancellation() async throws {
        let downloader = MTOfflineDownloader(maxInFlight: 2)
        
        actor CancellationTracker {
            var startedCount = 0
            var completedCount = 0
            var cancelledCount = 0
            
            func startTask() { startedCount += 1 }
            func endTask() { completedCount += 1 }
            func cancelTask() { cancelledCount += 1 }
        }
        
        let tracker = CancellationTracker()
        let taskReadyToCancel = expectation(description: "Tasks started")
        
        var tasks: [MockDownloadTask] = []
        // We add more tasks than the concurrency limit so some stay pending.
        for i in 0..<10 {
            let task = MockDownloadTask(id: "task-\(i)") {
                await tracker.startTask()
                
                if i == 0 {
                    // Signal that the first task has started, meaning the group is running
                    taskReadyToCancel.fulfill()
                }
                
                do {
                    // Sleep for a long time; this should be cancelled
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                    await tracker.endTask()
                } catch is CancellationError {
                    await tracker.cancelTask()
                    throw CancellationError()
                }
            }
            tasks.append(task)
        }
        
        // Start download in a detached task
        let downloadOperation = Task {
            try await downloader.download(tasks)
        }
        
        // Wait until at least one task starts
        await fulfillment(of: [taskReadyToCancel], timeout: 1.0)
        
        // Issue the cancellation
        await downloader.cancel()
        
        // The download operation should complete and throw CancellationError
        do {
            try await downloadOperation.value
            XCTFail("Download operation should have thrown a CancellationError")
        } catch is CancellationError {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        let started = await tracker.startedCount
        let completed = await tracker.completedCount
        let cancelled = await tracker.cancelledCount
        
        XCTAssertLessThanOrEqual(started, 2, "Only the tasks up to the concurrency limit should have started.")
        XCTAssertEqual(completed, 0, "No tasks should have completed fully because they were cancelled.")
        XCTAssertEqual(cancelled, started, "All started tasks should have been cancelled.")
    }
}
