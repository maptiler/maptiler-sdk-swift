//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import CoreLocation

@Suite
struct MTLngLatToStringTests {
    
    @Test func lngLatToStringCommand_shouldMatchJS() {
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)
        let expectedJS = "new \(MTBridge.sdkObject).LngLat(10.0, 50.0).toString();"
        
        #expect(LngLatToString(coordinate: coordinate).toJS() == expectedJS)
    }

    @MainActor
    @Test func lngLatToStringWrapper_shouldDispatchCommand_andReturnString() async throws {
        let expectedString = "LngLat(10.0, 50.0)"
        let executor = LngLatToStringMockExecutor(result: .string(expectedString))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)

        let result = await withCheckedContinuation { continuation in
            mapView.lngLatToString(coordinates: coordinate) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        switch result {
        case .success(let resultString):
            #expect(resultString == expectedString)
        case .failure(let error):
            Issue.record("Expected lngLatToString to succeed, but failed with \(error)")
        }
        
        #expect(executor.lastCommand is LngLatToString)
    }

    @MainActor
    @Test func lngLatToStringAsyncWrapper_shouldDispatchCommand_andReturnString() async {
        let expectedString = "LngLat(10.0, 50.0)"
        let executor = LngLatToStringMockExecutor(result: .string(expectedString))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)

        let resultString = await mapView.lngLatToString(coordinates: coordinate)
        
        #expect(resultString == expectedString)
        
        #expect(executor.lastCommand is LngLatToString)
    }
}

private final class LngLatToStringMockExecutor: MTCommandExecutable {
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
