//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBoundingBox.swift
//  MapTilerSDK
//

import Foundation

/// A bounding box in WGS84 coordinates.
public struct MTBoundingBox: Codable {
    public let minLon: Double
    public let minLat: Double
    public let maxLon: Double
    public let maxLat: Double

    public init(minLon: Double, minLat: Double, maxLon: Double, maxLat: Double) {
        self.minLon = minLon
        self.minLat = minLat
        self.maxLon = maxLon
        self.maxLat = maxLat
    }

    /// Checks if this bounding box intersects with another bounding box.
    /// - Parameter other: The other bounding box to check against.
    /// - Returns: `true` if the bounding boxes intersect, otherwise `false`.
    public func intersects(with other: MTBoundingBox) -> Bool {
        return !(self.minLon > other.maxLon ||
            self.maxLon < other.minLon ||
            self.minLat > other.maxLat ||
            self.maxLat < other.minLat)
    }
}
