//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineCoverageInputsTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

@Suite("MTOfflineCoverageInputs Tests")
struct MTOfflineCoverageInputsTests {

    @Test("Zoom ranges clamp properly to 22")
    func testZoomRangeClamping() throws {
        let zoomRange = try MTOfflineZoomRange(minZoom: 20, maxZoom: 25)
        #expect(zoomRange.minZoom == 20)
        #expect(zoomRange.maxZoom == 22)
        
        let zoomRange2 = try MTOfflineZoomRange(minZoom: 25, maxZoom: 28)
        #expect(zoomRange2.minZoom == 22)
        #expect(zoomRange2.maxZoom == 22)
    }
    
    @Test("Negative zoom levels throw error")
    func testNegativeZoomRange() throws {
        #expect(throws: MTOfflineCoverageInputError.invalidZoom("minZoom cannot be negative")) {
            _ = try MTOfflineZoomRange(minZoom: -1, maxZoom: 10)
        }
        
        #expect(throws: MTOfflineCoverageInputError.invalidZoom("maxZoom cannot be negative")) {
            _ = try MTOfflineZoomRange(minZoom: 0, maxZoom: -5)
        }
    }
    
    @Test("minZoom > maxZoom throws error")
    func testMinZoomGreaterThanMaxZoom() throws {
        #expect(throws: MTOfflineCoverageInputError.invalidZoomRange("minZoom (10) cannot be greater than maxZoom (5)")) {
            _ = try MTOfflineZoomRange(minZoom: 10, maxZoom: 5)
        }
    }
    
    @Test("Valid tile sizes are accepted")
    func testValidTileSizes() throws {
        let size256 = try MTOfflineTileSize(validating: 256)
        #expect(size256 == .size256)
        
        let size512 = try MTOfflineTileSize(validating: 512)
        #expect(size512 == .size512)
    }
    
    @Test("Invalid tile sizes throw error")
    func testInvalidTileSizes() throws {
        #expect(throws: MTOfflineCoverageInputError.invalidTileSize("Tile size must be 256 or 512, received 128")) {
            _ = try MTOfflineTileSize(validating: 128)
        }
    }
    
    @Test("Scheme defaults to XYZ if unspecified")
    func testSchemeDefaultsToXYZ() throws {
        let inputs = try MTOfflineCoverageInputs(scheme: nil, minZoom: 0, maxZoom: 5)
        #expect(inputs.scheme == .xyz)
    }
    
    @Test("Valid schemes are parsed correctly, ignoring case")
    func testValidSchemes() throws {
        let inputs1 = try MTOfflineCoverageInputs(scheme: "tms", minZoom: 0, maxZoom: 5)
        #expect(inputs1.scheme == .tms)
        
        let inputs2 = try MTOfflineCoverageInputs(scheme: "TMS", minZoom: 0, maxZoom: 5)
        #expect(inputs2.scheme == .tms)
        
        let inputs3 = try MTOfflineCoverageInputs(scheme: "xyz", minZoom: 0, maxZoom: 5)
        #expect(inputs3.scheme == .xyz)
        
        let inputs4 = try MTOfflineCoverageInputs(scheme: "XyZ", minZoom: 0, maxZoom: 5)
        #expect(inputs4.scheme == .xyz)
    }
    
    @Test("Invalid schemes throw error")
    func testInvalidSchemes() throws {
        #expect(throws: MTOfflineCoverageInputError.invalidScheme("Invalid scheme string: quadkey")) {
            _ = try MTOfflineCoverageInputs(scheme: "quadkey", minZoom: 0, maxZoom: 5)
        }
    }
    
    @Test("Full coverage input initialization stores all values properly")
    func testFullInitialization() throws {
        let inputs = try MTOfflineCoverageInputs(scheme: "tms", minZoom: 1, maxZoom: 10, tileSize: 256)
        #expect(inputs.scheme == .tms)
        #expect(inputs.zoomRange.minZoom == 1)
        #expect(inputs.zoomRange.maxZoom == 10)
        #expect(inputs.tileSize == .size256)
    }
}
