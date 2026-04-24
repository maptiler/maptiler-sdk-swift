//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

@Suite("MTGlyphHelper Tests")
struct MTGlyphHelperTests {
    
    @Test("Generate 256-step ranges for BMP")
    func generateRanges() {
        let ranges = MTGlyphHelper.generateRanges(upTo: 65535)
        
        // 65536 / 256 = 256 ranges
        #expect(ranges.count == 256)
        
        // Check first few ranges
        #expect(ranges[0].start == 0)
        #expect(ranges[0].end == 255)
        #expect(ranges[0].description == "0-255")
        
        #expect(ranges[1].start == 256)
        #expect(ranges[1].end == 511)
        #expect(ranges[1].description == "256-511")
        
        // Check last range
        #expect(ranges[255].start == 65280)
        #expect(ranges[255].end == 65535)
        #expect(ranges[255].description == "65280-65535")
    }
    
    @Test("Generate ranges for custom max index")
    func generateCustomRanges() {
        // Up to 511 should produce 2 ranges: 0-255 and 256-511
        let ranges = MTGlyphHelper.generateRanges(upTo: 511)
        #expect(ranges.count == 2)
        #expect(ranges[0].description == "0-255")
        #expect(ranges[1].description == "256-511")
        
        // Up to 300 should also produce 2 ranges (standard 256-step blocks)
        let ranges2 = MTGlyphHelper.generateRanges(upTo: 300)
        #expect(ranges2.count == 2)
        #expect(ranges2[0].description == "0-255")
        #expect(ranges2[1].description == "256-511")
    }
    
    @Test("Format glyph URL template with font stack and range")
    func formatTemplate() {
        let template = "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf?key=YOUR_KEY"
        let fonts = ["Noto Sans Regular", "Roboto Regular"]
        let range = MTGlyphRange(start: 0, end: 255)
        
        let formatted = MTGlyphHelper.format(template: template, fonts: fonts, range: range)
        
        // Note: percent encoding might turn spaces into %20
        #expect(formatted.contains("Noto%20Sans%20Regular,Roboto%20Regular"))
        #expect(formatted.contains("0-255.pbf"))
        #expect(formatted.contains("key=YOUR_KEY"))
    }
    
    @Test("Format glyph URL with complex font stack")
    func formatComplexTemplate() {
        let template = "maptiler://fonts/{fontstack}/{range}.pbf"
        let fontStack = "Open Sans Bold, Arial Unicode MS Regular"
        let rangeStr = "256-511"
        
        let formatted = MTGlyphHelper.format(template: template, fontStack: fontStack, range: rangeStr)
        
        #expect(formatted.contains("Open%20Sans%20Bold,%20Arial%20Unicode%20MS%20Regular"))
        #expect(formatted.contains("256-511.pbf"))
    }
}
