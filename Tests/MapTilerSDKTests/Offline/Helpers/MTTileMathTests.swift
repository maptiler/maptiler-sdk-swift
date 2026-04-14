//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileMathTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

@Suite("MTTileMath Tests")
struct MTTileMathTests {
    
    @Test("Tile bounds calculation at zoom 0")
    func testTileBoundsZoom0() throws {
        // Global bounds
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let bounds = MTTileMath.tileBounds(for: bbox, zoom: 0)
        
        #expect(bounds.minX == 0)
        #expect(bounds.maxX == 0)
        #expect(bounds.minY == 0)
        #expect(bounds.maxY == 0)
    }

    @Test("Tile bounds calculation at zoom 1")
    func testTileBoundsZoom1() throws {
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let bounds = MTTileMath.tileBounds(for: bbox, zoom: 1)
        
        #expect(bounds.minX == 0)
        #expect(bounds.maxX == 1)
        #expect(bounds.minY == 0)
        #expect(bounds.maxY == 1)
    }
    
    @Test("Tile count estimation calculates correct totals")
    func testTileCountEstimation() throws {
        // Global bounds
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let zoomRange = try MTOfflineZoomRange(minZoom: 0, maxZoom: 3)
        
        let totalTiles = MTTileMath.estimateTileCount(for: bbox, zoomRange: zoomRange)
        // Zoom 0 = 1, Zoom 1 = 4, Zoom 2 = 16, Zoom 3 = 64. Total = 85
        #expect(totalTiles == 85)
    }

    @Test("Y coordinate flipping for TMS")
    func testFlipYCoordinate() {
        // Zoom 0: max Y is 0. 0 -> 0.
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 0) == 0)
        
        // Zoom 1: max Y is 1. 0 -> 1, 1 -> 0.
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 1) == 1)
        #expect(MTTileMath.flipYCoordinate(y: 1, zoom: 1) == 0)
        
        // Zoom 2: max Y is 3. 0 -> 3, 1 -> 2.
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 2) == 3)
        #expect(MTTileMath.flipYCoordinate(y: 1, zoom: 2) == 2)

        // Extreme zoom levels (prevent overflow)
        let maxTileAt62 = (1 << 62) - 1
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 64) == maxTileAt62)
        #expect(MTTileMath.flipYCoordinate(y: 10, zoom: 64) == maxTileAt62 - 10)
    }

    @Test("Tile X Calculation")
    func testLongitudeToTileX() {
        #expect(MTTileMath.longitudeToTileX(lon: 0.0, zoom: 0) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: -180.0, zoom: 0) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: -90.0, zoom: 1) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: 90.0, zoom: 1) == 1)
        #expect(MTTileMath.longitudeToTileX(lon: 0.0, zoom: 2) == 2)
    }

    @Test("Tile Y Calculation")
    func testLatitudeToTileY() {
        #expect(MTTileMath.latitudeToTileY(lat: 0.0, zoom: 0) == 0)
        #expect(MTTileMath.latitudeToTileY(lat: 45.0, zoom: 1) == 0)
        #expect(MTTileMath.latitudeToTileY(lat: -45.0, zoom: 1) == 1)
        
        let maxYZoom2 = MTTileMath.latitudeToTileY(lat: -90.0, zoom: 2)
        #expect(maxYZoom2 == 3)
        
        let minYZoom2 = MTTileMath.latitudeToTileY(lat: 90.0, zoom: 2)
        #expect(minYZoom2 == 0)
    }

    @Test("Tile Ranges Calculation")
    func testTileRanges() {
        let bboxGlobe = MTBoundingBox(minLon: -180.0, minLat: -85.05112878, maxLon: 180.0, maxLat: 85.05112878)
        let rangesZ0 = MTTileMath.tileRanges(for: bboxGlobe, zoom: 0)
        #expect(rangesZ0.x == 0...0)
        #expect(rangesZ0.y == 0...0)
        
        let bbox = MTBoundingBox(minLon: -90.0, minLat: 0.0, maxLon: 0.0, maxLat: 45.0)
        let rangesZ2 = MTTileMath.tileRanges(for: bbox, zoom: 2)
        
        #expect(rangesZ2.x == 1...2)
        #expect(rangesZ2.y == 1...2)
    }
}
