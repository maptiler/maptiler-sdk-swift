//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBoundingBox.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation

/// A bounding box in WGS84 coordinates.
public struct MTBoundingBox: Codable, Equatable {
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

// MARK: - Normalization & Dateline Splitting
extension MTBoundingBox {
    /// The maximum latitude limit for Web Mercator projection.
    public static let maxWebMercatorLat: Double = 85.05112877980659

    /// Normalizes a longitude to the standard range [-180, 180].
    /// - Parameter longitude: The raw longitude.
    /// - Returns: A normalized longitude.
    public static func normalizeLongitude(_ longitude: Double) -> Double {
        var lon = longitude.truncatingRemainder(dividingBy: 360.0)
        if lon > 180.0 {
            lon -= 360.0
        } else if lon < -180.0 {
            lon += 360.0
        }
        return lon
    }

    /// Clamps a latitude to the Web Mercator valid range (-85.0511... to 85.0511...).
    /// - Parameter latitude: The raw latitude.
    /// - Returns: A clamped latitude.
    public static func clampLatitude(_ latitude: Double) -> Double {
        return min(max(latitude, -maxWebMercatorLat), maxWebMercatorLat)
    }

    /// Normalizes the bounding box coordinates and splits it into two if it crosses the antimeridian (Dateline).
    /// - Returns: An array containing one normalized bounding box, or two if it crosses the antimeridian.
    public func normalizedAndSplit() -> [MTBoundingBox] {
        let cMinLat = MTBoundingBox.clampLatitude(minLat)
        let cMaxLat = MTBoundingBox.clampLatitude(maxLat)

        // Handle bounding boxes covering or exceeding the entire globe's width
        if (maxLon - minLon) >= 360.0 {
            return [MTBoundingBox(minLon: -180.0, minLat: cMinLat, maxLon: 180.0, maxLat: cMaxLat)]
        }

        let nMinLon = MTBoundingBox.normalizeLongitude(minLon)
        let nMaxLon = MTBoundingBox.normalizeLongitude(maxLon)
        let normalizedBox = MTBoundingBox(minLon: nMinLon, minLat: cMinLat, maxLon: nMaxLon, maxLat: cMaxLat)

        if normalizedBox.crossesAntimeridian {
            let leftBox = MTBoundingBox(minLon: nMinLon, minLat: cMinLat, maxLon: 180.0, maxLat: cMaxLat)
            let rightBox = MTBoundingBox(minLon: -180.0, minLat: cMinLat, maxLon: nMaxLon, maxLat: cMaxLat)
            return [leftBox, rightBox]
        } else {
            return [normalizedBox]
        }
    }
}

// MARK: - Interoperability & Helper Utilities
extension MTBoundingBox {

    /// Initializes a bounding box from an `MTBounds` instance.
    /// - Parameter bounds: The source `MTBounds`.
    public init(bounds: MTBounds) {
        self.init(
            minLon: bounds.southWest.longitude,
            minLat: bounds.southWest.latitude,
            maxLon: bounds.northEast.longitude,
            maxLat: bounds.northEast.latitude
        )
    }

    /// Creates a bounding box from an array of coordinates.
    /// - Parameter coordinates: An array of coordinates (e.g. forming a polygon or line).
    /// - Returns: A bounding box enclosing all coordinates, or nil if the array is empty.
    public init?(coordinates: [CLLocationCoordinate2D]) {
        guard let first = coordinates.first else { return nil }
        var minLon = first.longitude
        var minLat = first.latitude
        var maxLon = first.longitude
        var maxLat = first.latitude

        for coord in coordinates.dropFirst() {
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
        }

        self.init(minLon: minLon, minLat: minLat, maxLon: maxLon, maxLat: maxLat)
    }

    /// Returns an equivalent `MTBounds` instance.
    public var bounds: MTBounds {
        return MTBounds(
            southWest: CLLocationCoordinate2D(latitude: minLat, longitude: minLon),
            northEast: CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)
        )
    }

    /// Expands the bounding box outward by a given percentage.
    /// - Parameter percentage: The percentage to expand (e.g., 0.1 for a 10% buffer).
    /// - Returns: A new expanded bounding box.
    public func expanded(by percentage: Double) -> MTBoundingBox {
        let latSpan = maxLat - minLat
        let lonSpan: Double
        if crossesAntimeridian {
            lonSpan = (180.0 - minLon) + (maxLon - (-180.0))
        } else {
            lonSpan = maxLon - minLon
        }

        let latPad = latSpan * percentage
        let lonPad = lonSpan * percentage

        let newMinLat = MTBoundingBox.clampLatitude(minLat - latPad)
        let newMaxLat = MTBoundingBox.clampLatitude(maxLat + latPad)
        let newMinLon = MTBoundingBox.normalizeLongitude(minLon - lonPad)
        let newMaxLon = MTBoundingBox.normalizeLongitude(maxLon + lonPad)

        return MTBoundingBox(minLon: newMinLon, minLat: newMinLat, maxLon: newMaxLon, maxLat: newMaxLat)
    }

    /// Calculates the approximate surface area in square kilometers.
    public var areaInSquareKilometers: Double {
        let earthRadiusKm = 6371.0
        let lat1 = minLat * .pi / 180.0
        let lat2 = maxLat * .pi / 180.0

        let lonSpan: Double
        if crossesAntimeridian {
            lonSpan = (180.0 - minLon) + (maxLon - (-180.0))
        } else {
            lonSpan = maxLon - minLon
        }

        let lonSpanRad = lonSpan * .pi / 180.0
        return pow(earthRadiusKm, 2) * lonSpanRad * abs(sin(lat2) - sin(lat1))
    }

    /// Estimates the exact number of tiles required for this bounding box within the specified zoom range.
    /// - Parameter zoomRange: The min and max zoom levels.
    /// - Returns: The total tile count.
    public func estimatedTileCount(zoomRange: MTOfflineZoomRange) -> Int {
        return MTOfflineTileCalculator.estimateTileCount(for: self, zoomRange: zoomRange)
    }
}
