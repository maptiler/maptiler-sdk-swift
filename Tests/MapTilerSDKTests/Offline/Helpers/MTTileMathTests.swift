//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileMathTests.swift
//  MapTilerSDKTests
//

import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTTileMath Robust Logic Tests")
struct MTTileMathTests {
    
    // MARK: - TMS Flip Tests
    
    @Test("Y coordinate flipping for TMS across zoom levels")
    func testFlipYCoordinate() {
        // Zoom 0: max Y is 0. 0 -> 0.
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 0) == 0)
        
        // Zoom 1: max Y is 1. 0 -> 1, 1 -> 0.
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 1) == 1)
        #expect(MTTileMath.flipYCoordinate(y: 1, zoom: 1) == 0)
        
        // Zoom 2: max Y is 3. 0 -> 3, 1 -> 2, 2 -> 1, 3 -> 0.
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 2) == 3)
        #expect(MTTileMath.flipYCoordinate(y: 1, zoom: 2) == 2)
        #expect(MTTileMath.flipYCoordinate(y: 2, zoom: 2) == 1)
        #expect(MTTileMath.flipYCoordinate(y: 3, zoom: 2) == 0)

        // Zoom 10: max Y is 1023.
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 10) == 1023)
        #expect(MTTileMath.flipYCoordinate(y: 512, zoom: 10) == 511)
        #expect(MTTileMath.flipYCoordinate(y: 1023, zoom: 10) == 0)

        // Extreme zoom levels (prevent overflow, capped at 62)
        let maxTileAt62 = (1 << 62) - 1
        #expect(MTTileMath.flipYCoordinate(y: 0, zoom: 62) == maxTileAt62)
        #expect(MTTileMath.flipYCoordinate(y: 10, zoom: 64) == maxTileAt62 - 10)
    }

    // MARK: - Tile Coordinate Conversion Tests
    
    @Test("Longitude to Tile X conversion at various zooms")
    func testLongitudeToTileX() {
        // Zoom 0: center of the world is tile 0
        #expect(MTTileMath.longitudeToTileX(lon: 0, zoom: 0) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: -180, zoom: 0) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: 180, zoom: 0) == 0)
        
        // Zoom 1: -180..0 is tile 0, 0..180 is tile 1
        #expect(MTTileMath.longitudeToTileX(lon: -179.9, zoom: 1) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: -0.1, zoom: 1) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: 0.1, zoom: 1) == 1)
        #expect(MTTileMath.longitudeToTileX(lon: 179.9, zoom: 1) == 1)
        
        // Zoom 2: quadrants
        #expect(MTTileMath.longitudeToTileX(lon: -91, zoom: 2) == 0)
        #expect(MTTileMath.longitudeToTileX(lon: -89, zoom: 2) == 1)
        #expect(MTTileMath.longitudeToTileX(lon: -1, zoom: 2) == 1)
        #expect(MTTileMath.longitudeToTileX(lon: 1, zoom: 2) == 2)
        #expect(MTTileMath.longitudeToTileX(lon: 89, zoom: 2) == 2)
        #expect(MTTileMath.longitudeToTileX(lon: 91, zoom: 2) == 3)
    }
    
    @Test("Latitude to Tile Y conversion at various zooms")
    func testLatitudeToTileY() {
        // Zoom 0: center of the world is tile 0
        #expect(MTTileMath.latitudeToTileY(lat: 0, zoom: 0) == 0)
        
        // Zoom 1: North (85..0) is tile 0, South (0..-85) is tile 1
        #expect(MTTileMath.latitudeToTileY(lat: 80, zoom: 1) == 0)
        #expect(MTTileMath.latitudeToTileY(lat: 1, zoom: 1) == 0)
        #expect(MTTileMath.latitudeToTileY(lat: -1, zoom: 1) == 1)
        #expect(MTTileMath.latitudeToTileY(lat: -80, zoom: 1) == 1)
        
        // Edge cases for Web Mercator limits
        #expect(MTTileMath.latitudeToTileY(lat: 85.0511, zoom: 1) == 0)
        #expect(MTTileMath.latitudeToTileY(lat: -85.0511, zoom: 1) == 1)
        #expect(MTTileMath.latitudeToTileY(lat: 90, zoom: 1) == 0)
        #expect(MTTileMath.latitudeToTileY(lat: -90, zoom: 1) == 1)
    }

    // MARK: - Tile Bounds and Buffers
    
    @Test("Tile bounds calculation with buffers and clamping")
    func testTileBoundsWithBufferAndClamping() {
        // Small box in the middle of a tile at zoom 4 (16x16)
        // Center is (8, 8)
        let bbox = MTBoundingBox(minLon: -1, minLat: -1, maxLon: 1, maxLat: 1)
        
        // Zero buffer
        let bounds0 = MTTileMath.tileBounds(for: bbox, zoom: 4, buffer: 0)
        #expect(bounds0.minX == 7)
        #expect(bounds0.maxX == 8)
        #expect(bounds0.minY == 7)
        #expect(bounds0.maxY == 8)
        
        // Buffer 1
        let bounds1 = MTTileMath.tileBounds(for: bbox, zoom: 4, buffer: 1)
        #expect(bounds1.minX == 6)
        #expect(bounds1.maxX == 9)
        #expect(bounds1.minY == 6)
        #expect(bounds1.maxY == 9)
        
        // Buffer causing clamping at top-left (0,0)
        let bboxTopLeft = MTBoundingBox(minLon: -179, minLat: 84, maxLon: -178, maxLat: 85)
        let boundsClamped = MTTileMath.tileBounds(for: bboxTopLeft, zoom: 4, buffer: 5)
        #expect(boundsClamped.minX == 0)
        #expect(boundsClamped.minY == 0)
        
        // Buffer causing clamping at bottom-right (15,15)
        let bboxBottomRight = MTBoundingBox(minLon: 178, minLat: -85, maxLon: 179, maxLat: -84)
        let boundsClampedEnd = MTTileMath.tileBounds(for: bboxBottomRight, zoom: 4, buffer: 5)
        #expect(boundsClampedEnd.maxX == 15)
        #expect(boundsClampedEnd.maxY == 15)
    }

    // MARK: - Tile Count Estimation
    
    @Test("Tile count estimation for various scenarios")
    func testTileCountEstimation() throws {
        // Global bounds
        let bboxGlobal = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let zRange = try MTOfflineZoomRange(minZoom: 0, maxZoom: 2)
        
        // z0: 1, z1: 4, z2: 16. Total = 21.
        let countGlobal = MTTileMath.estimateTileCount(for: bboxGlobal, zoomRange: zRange, buffer: 0)
        #expect(countGlobal == 21)
        
        // Antimeridian crossing: 170 to -170 (20 degrees span)
        // Splits into [170, 180] and [-180, -170].
        // At zoom 1: [170, 180] is in tile X=1. [-180, -170] is in tile X=0.
        // If latitude spans both hemispheres, it might take all Y tiles.
        let bboxAnti = MTBoundingBox(minLon: 170, minLat: -10, maxLon: -170, maxLat: 10)
        let z1Only = try MTOfflineZoomRange(minZoom: 1, maxZoom: 1)
        
        // At zoom 1:
        // Left split (170..180): X=1, Y=[0,1] -> 2 tiles
        // Right split (-180..-170): X=0, Y=[0,1] -> 2 tiles
        // Total = 4 tiles. (This specific small box covers both Y tiles because it crosses the equator).
        let countAnti = MTTileMath.estimateTileCount(for: bboxAnti, zoomRange: z1Only, buffer: 0)
        #expect(countAnti == 4)
    }

    @Test("Tile count per zoom estimation")
    func testTileCountPerZoom() throws {
        let bbox = MTBoundingBox(minLon: -1, minLat: -1, maxLon: 1, maxLat: 1)
        let zRange = try MTOfflineZoomRange(minZoom: 0, maxZoom: 2)
        
        let counts = MTTileMath.estimateTileCountPerZoom(for: bbox, zoomRange: zRange, buffer: 0)
        
        #expect(counts[0] == 1)
        #expect(counts[1] == 4)
        #expect(counts[2] == 4) // Center 4 tiles at z2
    }
}
