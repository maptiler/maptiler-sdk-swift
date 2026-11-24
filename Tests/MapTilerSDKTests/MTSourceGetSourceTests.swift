//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation
import CoreLocation
import UIKit

@Suite(.serialized)
struct MTSourceGetSourceTests {
    @MainActor
    @Test func geoJSONSource_getSource_shouldDispatchCommand() async throws {
        let executor = MockExecutor(result: .string("{\"type\":\"geojson\",\"data\":\"mock\"}"))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge?.executor = executor

        let source = MTGeoJSONSource(identifier: "my-geojson-source", url: URL(string: "https://example.com/data.geojson")!)

        let result = await source.getSource(in: mapView)
        
        #expect(result == "{\"type\":\"geojson\",\"data\":\"mock\"}")
        
        let command = executor.lastCommand as? GetSource
        #expect(command?.id == "my-geojson-source")
        
        let completionResult = await withCheckedContinuation { continuation in
            source.getSource(in: mapView) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        switch completionResult {
        case .success(let str):
            #expect(str == "{\"type\":\"geojson\",\"data\":\"mock\"}")
        case .failure(let error):
            Issue.record("Expected getSource wrapper to succeed, but failed with \(error)")
        }
    }

    @MainActor
    @Test func imageSource_getSource_shouldDispatchCommand() async throws {
        let executor = MockExecutor(result: .string("{\"type\":\"image\",\"url\":\"mock\"}"))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge?.executor = executor

        let coordinates = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 0, longitude: 1),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 1, longitude: 0)
        ]
        let source = MTImageSource(identifier: "my-image-source", url: URL(string: "https://example.com/image.png")!, coordinates: coordinates)

        let result = await source.getSource(in: mapView)
        
        #expect(result == "{\"type\":\"image\",\"url\":\"mock\"}")
        
        let command = executor.lastCommand as? GetSource
        #expect(command?.id == "my-image-source")
        
        let completionResult = await withCheckedContinuation { continuation in
            source.getSource(in: mapView) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        switch completionResult {
        case .success(let str):
            #expect(str == "{\"type\":\"image\",\"url\":\"mock\"}")
        case .failure(let error):
            Issue.record("Expected getSource wrapper to succeed, but failed with \(error)")
        }
    }

    @MainActor
    @Test func videoSource_getSource_shouldDispatchCommand() async throws {
        let executor = MockExecutor(result: .string("{\"type\":\"video\",\"urls\":[\"mock\"]}"))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge?.executor = executor

        let coordinates = [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 0, longitude: 1),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 1, longitude: 0)
        ]
        let source = MTVideoSource(identifier: "my-video-source", urls: [URL(string: "https://example.com/video.mp4")!], coordinates: coordinates)

        let result = await source.getSource(in: mapView)
        
        #expect(result == "{\"type\":\"video\",\"urls\":[\"mock\"]}")
        
        let command = executor.lastCommand as? GetSource
        #expect(command?.id == "my-video-source")
        
        let completionResult = await withCheckedContinuation { continuation in
            source.getSource(in: mapView) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        switch completionResult {
        case .success(let str):
            #expect(str == "{\"type\":\"video\",\"urls\":[\"mock\"]}")
        case .failure(let error):
            Issue.record("Expected getSource wrapper to succeed, but failed with \(error)")
        }
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