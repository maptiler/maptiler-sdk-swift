//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

struct MTTileRangeTests {

    @Test("Expand tile range with zero buffer")
    func testExpansionZeroBuffer() {
        let range = MTTileRange(minX: 2, maxX: 4, minY: 2, maxY: 4, zoom: 3)
        let expanded = range.expanded(by: 0)
        
        #expect(expanded.minX == 2)
        #expect(expanded.maxX == 4)
        #expect(expanded.minY == 2)
        #expect(expanded.maxY == 4)
        #expect(expanded.zoom == 3)
    }
    
    @Test("Expand tile range with positive buffer without hitting bounds")
    func testExpansionPositiveBuffer() {
        let range = MTTileRange(minX: 2, maxX: 4, minY: 2, maxY: 4, zoom: 4)
        let expanded = range.expanded(by: 1)
        
        #expect(expanded.minX == 1)
        #expect(expanded.maxX == 5)
        #expect(expanded.minY == 1)
        #expect(expanded.maxY == 5)
        #expect(expanded.zoom == 4)
    }

    @Test("Expand tile range and clamp at 0 (lower bounds)")
    func testExpansionClampsAtZero() {
        let range = MTTileRange(minX: 1, maxX: 3, minY: 1, maxY: 3, zoom: 3)
        let expanded = range.expanded(by: 2)
        
        #expect(expanded.minX == 0) // Clamped from -1
        #expect(expanded.maxX == 5)
        #expect(expanded.minY == 0) // Clamped from -1
        #expect(expanded.maxY == 5)
        #expect(expanded.zoom == 3)
    }

    @Test("Expand tile range and clamp at max limit (upper bounds)")
    func testExpansionClampsAtMaxLimit() {
        // At zoom level 3, max tile index is 2^3 - 1 = 7
        let range = MTTileRange(minX: 5, maxX: 6, minY: 5, maxY: 6, zoom: 3)
        let expanded = range.expanded(by: 2)
        
        #expect(expanded.minX == 3)
        #expect(expanded.maxX == 7) // Clamped from 8
        #expect(expanded.minY == 3)
        #expect(expanded.maxY == 7) // Clamped from 8
        #expect(expanded.zoom == 3)
    }
    
    @Test("Expand tile range and clamp at both bounds")
    func testExpansionClampsAtBothBounds() {
        // At zoom level 2, max tile index is 2^2 - 1 = 3
        let range = MTTileRange(minX: 1, maxX: 2, minY: 1, maxY: 2, zoom: 2)
        let expanded = range.expanded(by: 5)
        
        #expect(expanded.minX == 0) // Clamped from -4
        #expect(expanded.maxX == 3) // Clamped from 7
        #expect(expanded.minY == 0) // Clamped from -4
        #expect(expanded.maxY == 3) // Clamped from 7
        #expect(expanded.zoom == 2)
    }
}
