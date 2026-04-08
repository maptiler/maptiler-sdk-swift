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
    
    @Test("Zoom range clamps correctly to source limits")
    func testZoomRangeClampingToSource() throws {
        let requested = try MTOfflineZoomRange(minZoom: 0, maxZoom: 14)
        
        // Fully within limits
        let clamped1 = requested.clamped(toSourceMin: 0, sourceMax: 14)
        #expect(clamped1?.minZoom == 0)
        #expect(clamped1?.maxZoom == 14)
        
        // Clamped at both ends
        let clamped2 = requested.clamped(toSourceMin: 5, sourceMax: 10)
        #expect(clamped2?.minZoom == 5)
        #expect(clamped2?.maxZoom == 10)
        
        // Clamped only min
        let clamped3 = requested.clamped(toSourceMin: 2, sourceMax: 20)
        #expect(clamped3?.minZoom == 2)
        #expect(clamped3?.maxZoom == 14)
        
        // Clamped only max
        let clamped4 = requested.clamped(toSourceMin: 0, sourceMax: 8)
        #expect(clamped4?.minZoom == 0)
        #expect(clamped4?.maxZoom == 8)
        
        // Outside range (requested is below source min)
        let requestedLow = try MTOfflineZoomRange(minZoom: 0, maxZoom: 2)
        #expect(requestedLow.clamped(toSourceMin: 5, sourceMax: 10) == nil)
        
        // Outside range (requested is above source max)
        let requestedHigh = try MTOfflineZoomRange(minZoom: 15, maxZoom: 20)
        #expect(requestedHigh.clamped(toSourceMin: 0, sourceMax: 10) == nil)
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
    
    @Test("Scheme can be inferred from URL templates")
    func testSchemeInferredFromURL() {
        let xyzURL = "https://example.com/tiles/{z}/{x}/{y}.png"
        #expect(MTOfflineTileScheme.inferred(from: xyzURL) == .xyz)
        
        let tmsURL = "https://example.com/tiles/{z}/{x}/{-y}.png"
        #expect(MTOfflineTileScheme.inferred(from: tmsURL) == .tms)
        
        let invalidURL = "https://example.com/tiles/"
        #expect(MTOfflineTileScheme.inferred(from: invalidURL) == .xyz) // default
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
        
        let inputs512 = try MTOfflineCoverageInputs(scheme: "xyz", minZoom: 0, maxZoom: 22, tileSize: 512)
        #expect(inputs512.scheme == .xyz)
        #expect(inputs512.tileSize == .size512)
    }

    @Test("Tile size defaults to 512")
    func testTileSizeDefault() throws {
        let inputs = try MTOfflineCoverageInputs(minZoom: 0, maxZoom: 5)
        #expect(inputs.tileSize == .size512)
    }
}
