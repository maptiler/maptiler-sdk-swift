//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileStorageResolverTests.swift
//  MapTilerSDKTests
//

import XCTest
@testable import MapTilerSDK

final class MTTileStorageResolverTests: XCTestCase {

    func testResolveTilesForSingleSource() {
        let tiles = [
            MTOfflineTile(x: 1, y: 2, z: 3),
            MTOfflineTile(x: 0, y: 0, z: 0)
        ]
        
        let result = MTTileStorageResolver.resolve(tiles: tiles, sourceId: "maptiler-streets", extensionName: "pbf")
        
        XCTAssertEqual(result.count, 2)
        
        // Check sorting: z=0 should come before z=3
        XCTAssertEqual(result[0].tile, MTOfflineTile(x: 0, y: 0, z: 0))
        XCTAssertEqual(result[0].sourceId, "maptiler-streets")
        XCTAssertEqual(result[0].storagePath.path, "sources/maptiler-streets/0/0/0.pbf")
        
        XCTAssertEqual(result[1].tile, MTOfflineTile(x: 1, y: 2, z: 3))
        XCTAssertEqual(result[1].sourceId, "maptiler-streets")
        XCTAssertEqual(result[1].storagePath.path, "sources/maptiler-streets/3/1/2.pbf")
    }
    
    func testMergeAndResolveTiles() {
        let source1 = MTTileStorageResolver.SourceInput(sourceId: "satellite", extensionName: "webp")
        let source2 = MTTileStorageResolver.SourceInput(sourceId: "streets", extensionName: "pbf")
        
        let sources = [
            source2: [
                MTOfflineTile(x: 1, y: 1, z: 1),
                MTOfflineTile(x: 0, y: 0, z: 1)
            ],
            source1: [
                MTOfflineTile(x: 2, y: 2, z: 2)
            ]
        ]
        
        let result = MTTileStorageResolver.mergeAndResolve(sources: sources)
        
        XCTAssertEqual(result.count, 3)
        
        // Sorting should be: alphabetically by source ("satellite" < "streets"), then z, x, y
        
        // 1. satellite
        XCTAssertEqual(result[0].sourceId, "satellite")
        XCTAssertEqual(result[0].tile, MTOfflineTile(x: 2, y: 2, z: 2))
        XCTAssertEqual(result[0].storagePath.path, "sources/satellite/2/2/2.webp")
        
        // 2. streets (x=0)
        XCTAssertEqual(result[1].sourceId, "streets")
        XCTAssertEqual(result[1].tile, MTOfflineTile(x: 0, y: 0, z: 1))
        XCTAssertEqual(result[1].storagePath.path, "sources/streets/1/0/0.pbf")
        
        // 3. streets (x=1)
        XCTAssertEqual(result[2].sourceId, "streets")
        XCTAssertEqual(result[2].tile, MTOfflineTile(x: 1, y: 1, z: 1))
        XCTAssertEqual(result[2].storagePath.path, "sources/streets/1/1/1.pbf")
    }

    func testStableOrdering() {
        let sourceInput = MTTileStorageResolver.SourceInput(sourceId: "terrain", extensionName: "png")
        let tiles = [
            MTOfflineTile(x: 1, y: 1, z: 1),
            MTOfflineTile(x: 0, y: 1, z: 1),
            MTOfflineTile(x: 1, y: 0, z: 1),
            MTOfflineTile(x: 0, y: 0, z: 1),
            MTOfflineTile(x: 0, y: 0, z: 0)
        ]
        
        let result = MTTileStorageResolver.resolve(tiles: tiles, sourceId: sourceInput.sourceId, extensionName: sourceInput.extensionName)
        
        let expectedTiles = [
            MTOfflineTile(x: 0, y: 0, z: 0),
            MTOfflineTile(x: 0, y: 0, z: 1),
            MTOfflineTile(x: 0, y: 1, z: 1),
            MTOfflineTile(x: 1, y: 0, z: 1),
            MTOfflineTile(x: 1, y: 1, z: 1)
        ]
        
        XCTAssertEqual(result.map { $0.tile }, expectedTiles)
    }
}
