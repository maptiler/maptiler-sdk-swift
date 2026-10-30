//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineGlyphRanges.swift
//  MapTilerSDK
//

import Foundation

/// The Unicode ranges of label glyphs an offline pack downloads for each font of its style.
///
/// Glyphs come in ranges of 256 code points. Downloading every range of every font is large (about 38 MB per
/// font, mostly Chinese, Japanese and Korean characters), so packs download only the ranges they need. Characters
/// outside the downloaded ranges are not rendered offline.
public enum MTOfflineGlyphRanges: Codable, Equatable, Sendable {
    /// Latin (including extended Latin and Vietnamese), Greek and Cyrillic, plus common punctuation and symbols.
    case latinGreekCyrillic
    /// Every range of the Basic Multilingual Plane (256 ranges per font).
    case all
    /// Custom ranges, given by the first code point of each range (a multiple of 256, e.g. `0x4E00` for CJK).
    case custom([Int])

    /// The first code points of the ranges in `latinGreekCyrillic`.
    public static let latinGreekCyrillicStarts = [
        0x0000, // Basic Latin, Latin-1 Supplement
        0x0100, // Latin Extended-A and -B
        0x0200, // Latin Extended-B, IPA, spacing modifiers
        0x0300, // Combining diacritics, Greek
        0x0400, // Cyrillic
        0x0500, // Cyrillic Supplement
        0x1D00, // Phonetic extensions
        0x1E00, // Latin Extended Additional (Vietnamese)
        0x1F00, // Greek Extended
        0x2000, // General punctuation, super- and subscripts, currency symbols
        0x2100 // Letterlike symbols, number forms, arrows
    ]

    /// The first code points of the downloaded ranges, sorted and without duplicates.
    public var rangeStarts: [Int] {
        switch self {
        case .latinGreekCyrillic:
            return MTOfflineGlyphRanges.latinGreekCyrillicStarts
        case .all:
            return Array(stride(from: 0, through: MTGlyphHelper.defaultMaxIndex, by: 256))
        case .custom(let starts):
            return Array(Set(starts.map { ($0 / 256) * 256 }.filter { $0 >= 0 && $0 <= MTGlyphHelper.defaultMaxIndex }))
                .sorted()
        }
    }

    internal var ranges: [MTGlyphRange] {
        rangeStarts.map { MTGlyphRange(start: $0, end: $0 + 255) }
    }
}
