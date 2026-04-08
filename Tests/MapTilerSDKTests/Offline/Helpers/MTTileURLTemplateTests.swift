//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileURLTemplateTests.swift
//  MapTilerSDKTests
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("MTTileURLTemplate Tests")
struct MTTileURLTemplateTests {
    
    @Test("Validates correct templates")
    func testIsValid() {
        #expect(MTTileURLTemplate.isValid(template: "https://example.com/{z}/{x}/{y}.png"))
        #expect(MTTileURLTemplate.isValid(template: "https://example.com/{z}/{x}/{-y}.png"))
        #expect(MTTileURLTemplate.isValid(template: "maptiler://{z}/{x}/{y}"))
        
        #expect(!MTTileURLTemplate.isValid(template: "https://example.com/{z}/{x}.png"))
        #expect(!MTTileURLTemplate.isValid(template: "https://example.com/{z}/{y}.png"))
        #expect(!MTTileURLTemplate.isValid(template: "https://example.com/{x}/{y}.png"))
        #expect(!MTTileURLTemplate.isValid(template: "https://example.com/tiles.png"))
    }
    
    @Test("Builds correct URL for XYZ scheme")
    func testBuildURLXYZ() {
        let template = "https://example.com/{z}/{x}/{y}.png"
        let url = MTTileURLTemplate.buildURL(template: template, z: 1, x: 1, y: 1, scheme: .xyz)
        #expect(url?.absoluteString == "https://example.com/1/1/1.png")
    }
    
    @Test("Builds correct URL for TMS scheme using {-y}")
    func testBuildURLTMSInferred() {
        let template = "https://example.com/{z}/{x}/{-y}.png"
        // At zoom 1, max Y is 1. Flipped 1 is 0.
        let url = MTTileURLTemplate.buildURL(template: template, z: 1, x: 1, y: 1, scheme: .xyz)
        #expect(url?.absoluteString == "https://example.com/1/1/0.png")
    }
    
    @Test("Builds correct URL for TMS scheme using explicit enum")
    func testBuildURLExplicitTMS() {
        let template = "https://example.com/{z}/{x}/{y}.png"
        // At zoom 1, max Y is 1. Flipped 1 is 0.
        let url = MTTileURLTemplate.buildURL(template: template, z: 1, x: 1, y: 1, scheme: .tms)
        #expect(url?.absoluteString == "https://example.com/1/1/0.png")
    }
    
    @Test("Removes {ratio} if present")
    func testRemovesRatio() {
        let template = "https://example.com/{z}/{x}/{y}{ratio}.png"
        let url = MTTileURLTemplate.buildURL(template: template, z: 1, x: 1, y: 1, scheme: .xyz)
        #expect(url?.absoluteString == "https://example.com/1/1/1.png")
    }
}
