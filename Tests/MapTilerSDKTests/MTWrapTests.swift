//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import CoreLocation

@Suite
struct MTWrapTests {
    
    @Test func wrapCommand_shouldMatchJS() {
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 190.0)
        let expectedJS = "new \(MTBridge.sdkObject).LngLat(190.0, 50.0).wrap();"
        
        #expect(Wrap(coordinate: coordinate).toJS() == expectedJS)
    }

    @MainActor
    @Test func wrapWrapper_shouldDispatchCommand_andReturnCoordinate() async throws {
        let expectedLat = 50.0
        let expectedLng = -170.0
        let executor = WrapMockExecutor(result: .stringDoubleDict(["lat": expectedLat, "lng": expectedLng]))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 190.0)

        let result = await withCheckedContinuation { continuation in
            mapView.wrap(coordinates: coordinate) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        switch result {
        case .success(let resultCoord):
            #expect(resultCoord.latitude == expectedLat)
            #expect(resultCoord.longitude == expectedLng)
        case .failure(let error):
            Issue.record("Expected wrap to succeed, but failed with \(error)")
        }
        
        #expect(executor.lastCommand is Wrap)
    }

    @MainActor
    @Test func wrapAsyncWrapper_shouldDispatchCommand_andReturnCoordinate() async {
        let expectedLat = 50.0
        let expectedLng = -170.0
        let executor = WrapMockExecutor(result: .stringDoubleDict(["lat": expectedLat, "lng": expectedLng]))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 190.0)

        let resultCoord = await mapView.wrap(coordinates: coordinate)
        
        #expect(resultCoord.latitude == expectedLat)
        #expect(resultCoord.longitude == expectedLng)
        
        #expect(executor.lastCommand is Wrap)
    }
}

private final class WrapMockExecutor: MTCommandExecutable {
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
