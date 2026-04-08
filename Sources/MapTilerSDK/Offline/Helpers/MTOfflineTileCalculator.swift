//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineTileCalculator.swift
//  MapTilerSDK
//

import Foundation

// Pure math helpers for Web Mercator calculations and offline estimation.
internal enum MTOfflineTileCalculator {

    // Converts an XYZ Y-coordinate to a TMS Y-coordinate, or vice-versa.
    internal static func flipYCoordinate(y: Int, zoom: Int) -> Int {
        let maxTileY = (1 << zoom) - 1
        return maxTileY - y
    }

    // Calculates the Web Mercator tile X coordinate for a given longitude and zoom level.
    internal static func longitudeToTileX(lon: Double, zoom: Int) -> Int {
        let maxTile = (1 << zoom) - 1
        let x = Int(floor((lon + 180.0) / 360.0 * pow(2.0, Double(zoom))))
        return Swift.max(0, Swift.min(x, maxTile))
    }

    // Calculates the Web Mercator tile Y coordinate (XYZ scheme) for a given latitude and zoom level.
    internal static func latitudeToTileY(lat: Double, zoom: Int) -> Int {
        let maxTile = (1 << zoom) - 1
        let latRad = lat * .pi / 180.0
        let secLat = 1.0 / cos(latRad)
        let lnValue = log(tan(latRad) + secLat)
        let y = Int(floor((1.0 - lnValue / .pi) / 2.0 * pow(2.0, Double(zoom))))
        return Swift.max(0, Swift.min(y, maxTile))
    }

    // Represents a range of tile coordinates.
    internal struct MTOfflineTileBounds {
        let minX: Int
        let minY: Int
        let maxX: Int
        let maxY: Int
    }

    // Calculates the discrete tile bounds (min/max X and Y) intersecting a bounding box at a given zoom level.
    internal static func tileBounds(for bbox: MTBoundingBox, zoom: Int) -> MTOfflineTileBounds {
        let minXRaw = longitudeToTileX(lon: bbox.minLon, zoom: zoom)
        let maxXRaw = longitudeToTileX(lon: bbox.maxLon, zoom: zoom)
        // Latitude is inverted in Web Mercator XYZ: maximum latitude maps to minimum Y.
        let minYRaw = latitudeToTileY(lat: bbox.maxLat, zoom: zoom)
        let maxYRaw = latitudeToTileY(lat: bbox.minLat, zoom: zoom)

        return MTOfflineTileBounds(
            minX: Swift.min(minXRaw, maxXRaw),
            minY: Swift.min(minYRaw, maxYRaw),
            maxX: Swift.max(minXRaw, maxXRaw),
            maxY: Swift.max(minYRaw, maxYRaw)
        )
    }

    // Computes the exact total number of tiles required to cover a bounding box over a range of zooms.
    internal static func estimateTileCount(for bbox: MTBoundingBox, zoomRange: MTOfflineZoomRange) -> Int {
        if bbox.crossesAntimeridian {
            let bbox1 = MTBoundingBox(minLon: bbox.minLon, minLat: bbox.minLat, maxLon: 180, maxLat: bbox.maxLat)
            let bbox2 = MTBoundingBox(minLon: -180, minLat: bbox.minLat, maxLon: bbox.maxLon, maxLat: bbox.maxLat)
            return estimateTileCount(for: bbox1, zoomRange: zoomRange) +
                estimateTileCount(for: bbox2, zoomRange: zoomRange)
        }

        var totalTiles = 0
        for zoom in zoomRange.minZoom...zoomRange.maxZoom {
            let bounds = tileBounds(for: bbox, zoom: zoom)
            let countX = bounds.maxX - bounds.minX + 1
            let countY = bounds.maxY - bounds.minY + 1
            totalTiles += countX * countY
        }
        return totalTiles
    }
}
