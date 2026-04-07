//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineTileCalculatorTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

@Suite("MTOfflineTileCalculator Tests")
struct MTOfflineTileCalculatorTests {
    
    @Test("Tile bounds calculation at zoom 0")
    func testTileBoundsZoom0() throws {
        // Global bounds
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let bounds = MTOfflineTileCalculator.tileBounds(for: bbox, zoom: 0)
        
        #expect(bounds.minX == 0)
        #expect(bounds.maxX == 0)
        #expect(bounds.minY == 0)
        #expect(bounds.maxY == 0)
    }

    @Test("Tile bounds calculation at zoom 1")
    func testTileBoundsZoom1() throws {
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let bounds = MTOfflineTileCalculator.tileBounds(for: bbox, zoom: 1)
        
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
        
        let totalTiles = MTOfflineTileCalculator.estimateTileCount(for: bbox, zoomRange: zoomRange)
        // Zoom 0 = 1, Zoom 1 = 4, Zoom 2 = 16, Zoom 3 = 64. Total = 85
        #expect(totalTiles == 85)
    }

    @Test("Y coordinate flipping for TMS")
    func testFlipYCoordinate() {
        // Zoom 0: max Y is 0. 0 -> 0.
        #expect(MTOfflineTileCalculator.flipYCoordinate(y: 0, zoom: 0) == 0)
        
        // Zoom 1: max Y is 1. 0 -> 1, 1 -> 0.
        #expect(MTOfflineTileCalculator.flipYCoordinate(y: 0, zoom: 1) == 1)
        #expect(MTOfflineTileCalculator.flipYCoordinate(y: 1, zoom: 1) == 0)
        
        // Zoom 2: max Y is 3. 0 -> 3, 1 -> 2.
        #expect(MTOfflineTileCalculator.flipYCoordinate(y: 0, zoom: 2) == 3)
        #expect(MTOfflineTileCalculator.flipYCoordinate(y: 1, zoom: 2) == 2)
    }
}
