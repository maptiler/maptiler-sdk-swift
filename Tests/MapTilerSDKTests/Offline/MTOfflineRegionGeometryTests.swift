//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflineRegionGeometry Tests")
struct MTOfflineRegionGeometryTests {

    @Test("Bounding Box Geometry bbox property")
    func testBoundingBoxBbox() {
        let bbox = MTBoundingBox(minLon: 10, minLat: 20, maxLon: 30, maxLat: 40)
        let geometry = MTOfflineRegionGeometry.boundingBox(bbox)
        
        #expect(geometry.bbox == bbox)
    }

    @Test("Route Geometry bbox calculation")
    func testRouteBbox() {
        let coords = [
            CLLocationCoordinate2D(latitude: 20, longitude: 10),
            CLLocationCoordinate2D(latitude: 40, longitude: 30),
            CLLocationCoordinate2D(latitude: 30, longitude: 20)
        ]
        let geometry = MTOfflineRegionGeometry.route(coords)
        
        let expectedBbox = MTBoundingBox(minLon: 10, minLat: 20, maxLon: 30, maxLat: 40)
        #expect(geometry.bbox == expectedBbox)
    }

    @Test("Route Geometry empty coordinates")
    func testEmptyRouteBbox() {
        let geometry = MTOfflineRegionGeometry.route([])
        let bbox = geometry.bbox
        
        #expect(bbox.minLon == 0)
        #expect(bbox.minLat == 0)
        #expect(bbox.maxLon == 0)
        #expect(bbox.maxLat == 0)
    }

    @Test("Codable Bounding Box Geometry")
    func testCodableBoundingBox() throws {
        let bbox = MTBoundingBox(minLon: 10, minLat: 20, maxLon: 30, maxLat: 40)
        let geometry = MTOfflineRegionGeometry.boundingBox(bbox)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(geometry)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MTOfflineRegionGeometry.self, from: data)
        
        #expect(decoded == geometry)
    }

    @Test("Codable Route Geometry")
    func testCodableRoute() throws {
        let coords = [
            CLLocationCoordinate2D(latitude: 20, longitude: 10),
            CLLocationCoordinate2D(latitude: 40, longitude: 30)
        ]
        let geometry = MTOfflineRegionGeometry.route(coords)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(geometry)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MTOfflineRegionGeometry.self, from: data)
        
        #expect(decoded == geometry)
    }
}
