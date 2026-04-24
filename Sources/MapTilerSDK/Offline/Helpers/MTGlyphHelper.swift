//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

// A utility for generating glyph ranges and formatting glyph URLs for offline use.
internal struct MTGlyphHelper {

    // The default maximum Unicode index to cover (Basic Multilingual Plane).
    internal static let defaultMaxIndex = 65535

    /// Generates the standard 256-step Unicode character ranges.
    internal static func generateRanges(upTo maxIndex: Int = defaultMaxIndex) -> [MTGlyphRange] {
        var ranges: [MTGlyphRange] = []
        // Standard Mapbox/MapLibre glyphs are requested in chunks of 256.
        // Start index is a multiple of 256, end index is start + 255.
        for start in stride(from: 0, through: maxIndex, by: 256) {
            let end = start + 255
            ranges.append(MTGlyphRange(start: start, end: end))
        }
        return ranges
    }

    /// Formats a glyph URL template with a font stack and a range.
    internal static func format(template: String, fonts: [String], range: MTGlyphRange) -> String {
        let fontStack = fonts.joined(separator: ",")
        return format(template: template, fontStack: fontStack, range: range.description)
    }

    /// Formats a glyph URL template with a font stack string and a range string.
    internal static func format(template: String, fontStack: String, range: String) -> String {
        let encodedFontStack = fontStack.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fontStack

        return template
            .replacingOccurrences(of: "{fontstack}", with: encodedFontStack)
            .replacingOccurrences(of: "{range}", with: range)
    }
}
