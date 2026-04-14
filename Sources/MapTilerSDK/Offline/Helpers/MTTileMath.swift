//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileMath.swift
//  MapTilerSDK
//

import Foundation

// Pure math helpers for Web Mercator calculations and offline estimation.
internal struct MTTileMath {

    // Helper to safely calculate the maximum tile index for a given zoom level without overflow
    internal static func safeMaxTile(for zoom: Int) -> Int {
        // Limit zoom to 62 to prevent (1 << zoom) from overflowing a 64-bit signed integer
        let safeZoom = Swift.max(0, Swift.min(zoom, 62))
        return (1 << safeZoom) - 1
    }

    // Converts an XYZ Y-coordinate to a TMS Y-coordinate, or vice-versa.
    internal static func flipYCoordinate(y: Int, zoom: Int) -> Int {
        let maxTileY = safeMaxTile(for: zoom)
        return maxTileY - y
    }

    // Calculates the Web Mercator tile X coordinate for a given longitude and zoom level.
    internal static func longitudeToTileX(lon: Double, zoom: Int) -> Int {
        let safeZoom = Swift.max(0, Swift.min(zoom, 62))
        let maxTile = safeMaxTile(for: safeZoom)
        let x = Int(MTMath.longitudeToTileX(longitude: lon, zoom: Double(safeZoom), round: true))
        return Swift.max(0, Swift.min(x, maxTile))
    }

    // Calculates the Web Mercator tile Y coordinate (XYZ scheme) for a given latitude and zoom level.
    internal static func latitudeToTileY(lat: Double, zoom: Int) -> Int {
        let safeZoom = Swift.max(0, Swift.min(zoom, 62))
        let maxTile = safeMaxTile(for: safeZoom)
        let clampedLat = Swift.max(Swift.min(lat, MTMath.maxSafeLatitude), -MTMath.maxSafeLatitude)
        let y = Int(MTMath.latitudeToTileY(latitude: clampedLat, zoom: Double(safeZoom), round: true))
        return Swift.max(0, Swift.min(y, maxTile))
    }

    // Represents a range of tile coordinates.
    internal struct MTTileBounds {
        let minX: Int
        let minY: Int
        let maxX: Int
        let maxY: Int
    }

    // Calculates the discrete tile bounds (min/max X and Y) intersecting a bounding box at a given zoom level.
    internal static func tileBounds(for bbox: MTBoundingBox, zoom: Int) -> MTTileBounds {
        let minXRaw = longitudeToTileX(lon: bbox.minLon, zoom: zoom)
        let maxXRaw = longitudeToTileX(lon: bbox.maxLon, zoom: zoom)
        // Latitude is inverted in Web Mercator XYZ: maximum latitude maps to minimum Y.
        let minYRaw = latitudeToTileY(lat: bbox.maxLat, zoom: zoom)
        let maxYRaw = latitudeToTileY(lat: bbox.minLat, zoom: zoom)

        return MTTileBounds(
            minX: Swift.min(minXRaw, maxXRaw),
            minY: Swift.min(minYRaw, maxYRaw),
            maxX: Swift.max(minXRaw, maxXRaw),
            maxY: Swift.max(minYRaw, maxYRaw)
        )
    }

    // Computes the exact total number of tiles required to cover a bounding box over a range of zooms.
    internal static func estimateTileCount(for bbox: MTBoundingBox, zoomRange: MTOfflineZoomRange) -> Int {
        let normalizedBoxes = bbox.normalizedAndSplit()
        var totalTiles = 0

        for box in normalizedBoxes {
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                let bounds = tileBounds(for: box, zoom: zoom)
                let countX = bounds.maxX - bounds.minX + 1
                let countY = bounds.maxY - bounds.minY + 1
                totalTiles += countX * countY
            }
        }
        return totalTiles
    }

    // Computes the exact number of tiles required per zoom level.
    internal static func estimateTileCountPerZoom(
        for bbox: MTBoundingBox,
        zoomRange: MTOfflineZoomRange
    ) -> [Int: Int] {
        let normalizedBoxes = bbox.normalizedAndSplit()
        var counts: [Int: Int] = [:]

        for box in normalizedBoxes {
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                let bounds = tileBounds(for: box, zoom: zoom)
                let countX = bounds.maxX - bounds.minX + 1
                let countY = bounds.maxY - bounds.minY + 1
                counts[zoom, default: 0] += countX * countY
            }
        }
        return counts
    }

    // Calculates the closed ranges of X and Y tile coordinates for a given bounding box and zoom level.
    internal static func tileRanges(for bbox: MTBoundingBox, zoom: Int) -> (x: ClosedRange<Int>, y: ClosedRange<Int>) {
        let bounds = tileBounds(for: bbox, zoom: zoom)
        return (x: bounds.minX...bounds.maxX, y: bounds.minY...bounds.maxY)
    }

    // Calculates the closed ranges of X and Y tile coordinates for a given bounding box and a range of zoom levels.
    internal static func tileRanges(
        for bbox: MTBoundingBox,
        zoomRange: ClosedRange<Int>
    ) -> [Int: (x: ClosedRange<Int>, y: ClosedRange<Int>)] {
        var result = [Int: (x: ClosedRange<Int>, y: ClosedRange<Int>)]()
        for z in zoomRange {
            result[z] = tileRanges(for: bbox, zoom: z)
        }
        return result
    }
}
