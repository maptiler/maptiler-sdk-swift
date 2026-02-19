//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import CoreLocation

@Suite
struct MTUnprojectTests {
    
    @Test func unprojectCommand_shouldMatchJS() {
        let point = MTPoint(x: 100, y: 200)
        let expectedJS = "\(MTBridge.mapObject).unproject([100.0, 200.0]);"
        
        #expect(Unproject(point: point).toJS() == expectedJS)
    }

    @MainActor
    @Test func unprojectWrapper_shouldDispatchCommand_andReturnCoordinate() async throws {
        let expectedLat = 10.0
        let expectedLng = 20.0
        let executor = MockExecutor(result: .stringDoubleDict(["lat": expectedLat, "lng": expectedLng]))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let point = MTPoint(x: 100, y: 200)

        let result = await withCheckedContinuation { continuation in
            mapView.unproject(point: point) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        switch result {
        case .success(let coordinate):
            #expect(coordinate.latitude == expectedLat)
            #expect(coordinate.longitude == expectedLng)
        case .failure(let error):
            Issue.record("Expected unproject to succeed, but failed with \(error)")
        }
        
        #expect(executor.lastCommand is Unproject)
    }

    @MainActor
    @Test func unprojectAsyncWrapper_shouldDispatchCommand_andReturnCoordinate() async {
        let expectedLat = 30.0
        let expectedLng = 40.0
        let executor = MockExecutor(result: .stringDoubleDict(["lat": expectedLat, "lng": expectedLng]))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let point = MTPoint(x: 300, y: 400)

        let coordinate = await mapView.unproject(point: point)
        
        #expect(coordinate.latitude == expectedLat)
        #expect(coordinate.longitude == expectedLng)
        
        #expect(executor.lastCommand is Unproject)
    }
}

private final class MockExecutor: MTCommandExecutable {
    var lastCommand: (any MTCommand)?
    var result: MTBridgeReturnType

    init(result: MTBridgeReturnType = .null) {
        self.result = result
    }

    func execute(_ command: MTCommand) async throws -> MTBridgeReturnType {
        lastCommand = command
        return result
    }
}
