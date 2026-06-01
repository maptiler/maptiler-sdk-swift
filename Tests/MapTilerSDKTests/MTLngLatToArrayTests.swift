//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import CoreLocation

@Suite
struct MTLngLatToArrayTests {
    
    @Test func lngLatToArrayCommand_shouldMatchJS() {
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)
        let expectedJS = "new \(MTBridge.sdkObject).LngLat(10.0, 50.0).toArray();"
        
        #expect(LngLatToArray(coordinate: coordinate).toJS() == expectedJS)
    }

    @MainActor
    @Test func lngLatToArrayWrapper_shouldDispatchCommand_andReturnArray() async throws {
        let expectedArray = [10.0, 50.0]
        let executor = LngLatToArrayMockExecutor(result: .doubleArray(expectedArray))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)

        let result = await withCheckedContinuation { continuation in
            mapView.lngLatToArray(coordinates: coordinate) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        switch result {
        case .success(let resultArray):
            #expect(resultArray == expectedArray)
        case .failure(let error):
            Issue.record("Expected lngLatToArray to succeed, but failed with \(error)")
        }
        
        #expect(executor.lastCommand is LngLatToArray)
    }

    @MainActor
    @Test func lngLatToArrayAsyncWrapper_shouldDispatchCommand_andReturnArray() async {
        let expectedArray = [10.0, 50.0]
        let executor = LngLatToArrayMockExecutor(result: .doubleArray(expectedArray))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor
        
        let coordinate = CLLocationCoordinate2D(latitude: 50.0, longitude: 10.0)

        let resultArray = await mapView.lngLatToArray(coordinates: coordinate)
        
        #expect(resultArray == expectedArray)
        
        #expect(executor.lastCommand is LngLatToArray)
    }
}

private final class LngLatToArrayMockExecutor: MTCommandExecutable {
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
