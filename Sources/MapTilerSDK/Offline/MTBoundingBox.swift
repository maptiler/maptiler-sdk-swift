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

    /// Returns `true` if the bounding box spans across the antimeridian (180th meridian).
    public var crossesAntimeridian: Bool {
        return minLon > maxLon
    }

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
        let lonIntersects: Bool
        if self.crossesAntimeridian {
            if other.crossesAntimeridian {
                lonIntersects = true
            } else {
                lonIntersects = other.minLon <= self.maxLon || other.maxLon >= self.minLon
            }
        } else if other.crossesAntimeridian {
            lonIntersects = self.minLon <= other.maxLon || self.maxLon >= other.minLon
        } else {
            lonIntersects = !(self.minLon > other.maxLon || self.maxLon < other.minLon)
        }
        let latIntersects = !(self.minLat > other.maxLat || self.maxLat < other.minLat)
        return lonIntersects && latIntersects
    }
}
