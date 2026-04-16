//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

/// Represents a range of map tiles at a specific zoom level.
public struct MTTileRange: Equatable, Sendable {
    public let minX: Int
    public let maxX: Int
    public let minY: Int
    public let maxY: Int
    public let zoom: Int

    public init(minX: Int, maxX: Int, minY: Int, maxY: Int, zoom: Int) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        self.zoom = zoom
    }

    /// Returns a new `MTTileRange` with the boundaries pushed outwards by the given buffer.
    /// Clamps the resulting indices to the valid `[0, 2^Z - 1]` range for the current zoom level.
    public func expanded(by buffer: Int) -> MTTileRange {
        let limit = (1 << zoom) - 1

        return MTTileRange(
            minX: max(0, minX - buffer),
            maxX: min(limit, maxX + buffer),
            minY: max(0, minY - buffer),
            maxY: min(limit, maxY + buffer),
            zoom: zoom
        )
    }
}
