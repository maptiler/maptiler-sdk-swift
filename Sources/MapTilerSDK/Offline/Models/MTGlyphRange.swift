//
// Copyright (c) 2026 MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

// Represents a 256-step Unicode character range used for downloading map glyphs.
internal struct MTGlyphRange: Hashable, Equatable, Sendable, CustomStringConvertible {
    // The start index of the range (inclusive).
    internal let start: Int

    // The end index of the range (inclusive).
    internal let end: Int

    // Initializes a new glyph range.
    internal init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }

    // A string representation of the range in the format "start-end" (e.g., "0-255").
    internal var description: String {
        "\(start)-\(end)"
    }
}
