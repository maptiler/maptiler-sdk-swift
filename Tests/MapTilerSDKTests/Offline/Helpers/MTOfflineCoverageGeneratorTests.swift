//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineCoverageGeneratorTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

@Suite("MTOfflineCoverageGenerator Tests")
struct MTOfflineCoverageGeneratorTests {
    
    @Test("Generates exactly 1 tile for global zoom 0")
    func testGeneratorGlobalZoom0() throws {
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let inputs = try MTOfflineCoverageInputs(scheme: "xyz", minZoom: 0, maxZoom: 0)
        let generator = MTOfflineCoverageGenerator(boundingBox: bbox, inputs: inputs)
        
        let tiles = Array(generator)
        #expect(tiles.count == 1)
        #expect(tiles.first == MTOfflineTile(x: 0, y: 0, z: 0))
    }
    
    @Test("Generates correct tiles for XYZ scheme")
    func testGeneratorXYZ() throws {
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let inputs = try MTOfflineCoverageInputs(scheme: "xyz", minZoom: 1, maxZoom: 1)
        let generator = MTOfflineCoverageGenerator(boundingBox: bbox, inputs: inputs)
        
        let tiles = Array(generator)
        #expect(tiles.count == 4)
        
        let expectedTiles: Set<MTOfflineTile> = [
            MTOfflineTile(x: 0, y: 0, z: 1),
            MTOfflineTile(x: 1, y: 0, z: 1),
            MTOfflineTile(x: 0, y: 1, z: 1),
            MTOfflineTile(x: 1, y: 1, z: 1)
        ]
        
        #expect(Set(tiles) == expectedTiles)
    }

    @Test("Generates correct tiles and flips Y for TMS scheme")
    func testGeneratorTMS() throws {
        let bbox = MTBoundingBox(minLon: -180, minLat: -85.0511, maxLon: 180, maxLat: 85.0511)
        let inputs = try MTOfflineCoverageInputs(scheme: "tms", minZoom: 1, maxZoom: 1)
        let generator = MTOfflineCoverageGenerator(boundingBox: bbox, inputs: inputs)
        
        let tiles = Array(generator)
        #expect(tiles.count == 4)
        
        // At zoom 1, XYZ Y coords 0 and 1 are flipped to 1 and 0 respectively for TMS.
        let expectedTiles: Set<MTOfflineTile> = [
            MTOfflineTile(x: 0, y: 1, z: 1),
            MTOfflineTile(x: 1, y: 1, z: 1),
            MTOfflineTile(x: 0, y: 0, z: 1),
            MTOfflineTile(x: 1, y: 0, z: 1)
        ]
        
        #expect(Set(tiles) == expectedTiles)
    }
    
    @Test("Tile generation count matches math estimation")
    func testGenerationMatchesEstimation() throws {
        let bbox = MTBoundingBox(minLon: -10, minLat: -10, maxLon: 10, maxLat: 10)
        let zoomRange = try MTOfflineZoomRange(minZoom: 1, maxZoom: 3)
        let inputs = try MTOfflineCoverageInputs(scheme: "xyz", minZoom: 1, maxZoom: 3)
        
        let estimatedCount = MTTileMath.estimateTileCount(for: bbox, zoomRange: zoomRange)
        
        let generator = MTOfflineCoverageGenerator(boundingBox: bbox, inputs: inputs)
        let tiles = Array(generator)
        
        #expect(tiles.count == estimatedCount)
    }
}
