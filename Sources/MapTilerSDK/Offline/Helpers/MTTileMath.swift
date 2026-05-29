//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileMath.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation

// Represents a specific tile coordinate.
internal struct MTTileIndex: Hashable, Equatable, Sendable {
    let x: Int
    let y: Int
    let z: Int
}

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

    // Calculates the required tile buffer size for a given distance padding in meters at a specific zoom and latitude.
    internal static func calculateTileBuffer(
        forPadding paddingMeters: Double?,
        boundingBox: MTBoundingBox,
        zoom: Int
    ) -> Int {
        guard let paddingMeters = paddingMeters else { return 1 } // Default fallback buffer
        guard paddingMeters > 0 else { return 0 }

        let maxAbsLat = Swift.max(abs(boundingBox.minLat), abs(boundingBox.maxLat))
        let clampedLat = Swift.min(maxAbsLat, MTMath.maxSafeLatitude)
        let cosLat = cos(MTMath.toRadians(degrees: clampedLat))
        let tilesAtZoom = pow(2.0, Double(Swift.max(0, Swift.min(zoom, 62))))
        let metersPerTile = (MTMath.earthCircumference * cosLat) / tilesAtZoom

        if metersPerTile <= 0 { return 1 }
        let requiredTiles = Int(ceil(paddingMeters / metersPerTile))
        return Swift.max(1, Swift.min(requiredTiles, 50)) // Cap at 50 to prevent excessive memory usage
    }

    // Calculates the discrete tile bounds (min/max X and Y) intersecting a bounding box at a given zoom level.
    internal static func tileBounds(for bbox: MTBoundingBox, zoom: Int, buffer: Int = 1) -> MTTileBounds {
        let minXRaw = longitudeToTileX(lon: bbox.minLon, zoom: zoom)
        let maxXRaw = longitudeToTileX(lon: bbox.maxLon, zoom: zoom)
        // Latitude is inverted in Web Mercator XYZ: maximum latitude maps to minimum Y.
        let minYRaw = latitudeToTileY(lat: bbox.maxLat, zoom: zoom)
        let maxYRaw = latitudeToTileY(lat: bbox.minLat, zoom: zoom)

        let minX = Swift.min(minXRaw, maxXRaw)
        let minY = Swift.min(minYRaw, maxYRaw)
        let maxX = Swift.max(minXRaw, maxXRaw)
        let maxY = Swift.max(minYRaw, maxYRaw)

        let maxIdx = safeMaxTile(for: zoom)

        return MTTileBounds(
            minX: Swift.max(0, minX - buffer),
            minY: Swift.max(0, minY - buffer),
            maxX: Swift.min(maxIdx, maxX + buffer),
            maxY: Swift.min(maxIdx, maxY + buffer)
        )
    }

    // Applies a buffer around a set of tiles
    internal static func applyBuffer(to tiles: Set<MTTileIndex>, buffer: Int) -> Set<MTTileIndex> {
        guard buffer > 0 else { return tiles }
        var result = Set<MTTileIndex>()
        for tile in tiles {
            let maxIdx = safeMaxTile(for: tile.z)
            for dx in -buffer...buffer {
                for dy in -buffer...buffer {
                    let nx = Swift.max(0, Swift.min(maxIdx, tile.x + dx))
                    let ny = Swift.max(0, Swift.min(maxIdx, tile.y + dy))
                    result.insert(MTTileIndex(x: nx, y: ny, z: tile.z))
                }
            }
        }
        return result
    }

    // Finds tiles intersected by a line segment using Amanatides-Woo DDA algorithm
    internal static func tilesIntersectingSegment(
        p1: (x: Double, y: Double),
        p2: (x: Double, y: Double),
        zoom: Int
    ) -> Set<MTTileIndex> {
        var result = Set<MTTileIndex>()
        let maxIdx = safeMaxTile(for: zoom)

        var x = Int(floor(p1.x))
        var y = Int(floor(p1.y))

        let endX = Int(floor(p2.x))
        let endY = Int(floor(p2.y))

        result.insert(MTTileIndex(
            x: Swift.max(0, Swift.min(maxIdx, x)),
            y: Swift.max(0, Swift.min(maxIdx, y)),
            z: zoom
        ))

        let dx = p2.x - p1.x
        let dy = p2.y - p1.y

        let stepX = dx > 0 ? 1 : (dx < 0 ? -1 : 0)
        let stepY = dy > 0 ? 1 : (dy < 0 ? -1 : 0)

        let tDeltaX = stepX != 0 ? abs(1.0 / dx) : Double.greatestFiniteMagnitude
        let tDeltaY = stepY != 0 ? abs(1.0 / dy) : Double.greatestFiniteMagnitude

        var tMaxX = stepX > 0 ? (floor(p1.x) + 1.0 - p1.x) * tDeltaX : (p1.x - floor(p1.x)) * tDeltaX
        var tMaxY = stepY > 0 ? (floor(p1.y) + 1.0 - p1.y) * tDeltaY : (p1.y - floor(p1.y)) * tDeltaY

        if tMaxX.isNaN || tMaxX.isInfinite { tMaxX = Double.greatestFiniteMagnitude }
        if tMaxY.isNaN || tMaxY.isInfinite { tMaxY = Double.greatestFiniteMagnitude }

        if tMaxX == 0 { tMaxX += tDeltaX }
        if tMaxY == 0 { tMaxY += tDeltaY }

        while x != endX || y != endY {
            if tMaxX < tMaxY {
                tMaxX += tDeltaX
                x += stepX
            } else if tMaxY < tMaxX {
                tMaxY += tDeltaY
                y += stepY
            } else {
                x += stepX
                y += stepY
                tMaxX += tDeltaX
                tMaxY += tDeltaY
            }
            result.insert(MTTileIndex(
                x: Swift.max(0, Swift.min(maxIdx, x)),
                y: Swift.max(0, Swift.min(maxIdx, y)),
                z: zoom
            ))
        }
        return result
    }

    // Calculates exactly which tiles cover a given route
    internal static func tiles(for route: [CLLocationCoordinate2D], zoom: Int, buffer: Int = 1) -> Set<MTTileIndex> {
        var tiles = Set<MTTileIndex>()
        guard !route.isEmpty else { return tiles }

        if route.count == 1 {
            let x = longitudeToTileX(lon: route[0].longitude, zoom: zoom)
            let y = latitudeToTileY(lat: route[0].latitude, zoom: zoom)
            tiles.insert(MTTileIndex(x: x, y: y, z: zoom))
            return applyBuffer(to: tiles, buffer: buffer)
        }

        let zoomDouble = Double(Swift.max(0, Swift.min(zoom, 62)))
        for i in 0..<(route.count - 1) {
            let p1 = route[i]
            let p2 = route[i + 1]

            let x1 = MTMath.longitudeToTileX(longitude: p1.longitude, zoom: zoomDouble, round: false)
            let y1 = MTMath.latitudeToTileY(latitude: p1.latitude, zoom: zoomDouble, round: false)
            let x2 = MTMath.longitudeToTileX(longitude: p2.longitude, zoom: zoomDouble, round: false)
            let y2 = MTMath.latitudeToTileY(latitude: p2.latitude, zoom: zoomDouble, round: false)

            let segmentTiles = tilesIntersectingSegment(p1: (x: x1, y: y1), p2: (x: x2, y: y2), zoom: zoom)
            tiles.formUnion(segmentTiles)
        }
        return applyBuffer(to: tiles, buffer: buffer)
    }

    private static func isPointInPolygon(point: CLLocationCoordinate2D, polygon: [CLLocationCoordinate2D]) -> Bool {
        var isInside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let pi = polygon[i]
            let pj = polygon[j]
            if (pi.latitude > point.latitude) != (pj.latitude > point.latitude) &&
                point.longitude < (pj.longitude - pi.longitude) * (point.latitude - pi.latitude) /
                (pj.latitude - pi.latitude) + pi.longitude {
                isInside.toggle()
            }
            j = i
        }
        return isInside
    }

    // Calculates exactly which tiles cover a given polygon
    internal static func tiles(
        forPolygon polygon: [CLLocationCoordinate2D],
        zoom: Int,
        buffer: Int = 1
    ) -> Set<MTTileIndex> {
        var tilesSet = Set<MTTileIndex>()
        guard polygon.count > 2 else {
            return tiles(for: polygon, zoom: zoom, buffer: buffer)
        }

        let bbox = MTBoundingBox(from: polygon)
        let bounds = tileBounds(for: bbox, zoom: zoom, buffer: 0)

        var closedPolygon = polygon
        if let first = closedPolygon.first, let last = closedPolygon.last,
            first.latitude != last.latitude || first.longitude != last.longitude {
            closedPolygon.append(first)
        }
        let edgeTiles = tiles(for: closedPolygon, zoom: zoom, buffer: 0)
        tilesSet.formUnion(edgeTiles)

        let n = pow(2.0, Double(zoom))
        for y in bounds.minY...bounds.maxY {
            for x in bounds.minX...bounds.maxX {
                let tile = MTTileIndex(x: x, y: y, z: zoom)
                if !tilesSet.contains(tile) {
                    let lon = (Double(x) + 0.5) / n * 360.0 - 180.0
                    let latRad = atan(sinh(.pi * (1.0 - 2.0 * (Double(y) + 0.5) / n)))
                    let lat = latRad * 180.0 / .pi

                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    if isPointInPolygon(point: coord, polygon: closedPolygon) {
                        tilesSet.insert(tile)
                    }
                }
            }
        }

        return applyBuffer(to: tilesSet, buffer: buffer)
    }

    // Resolves tiles for any geometry type
    internal static func tiles(
        for geometry: MTOfflineRegionGeometry,
        zoom: Int,
        paddingMeters: Double?
    ) -> Set<MTTileIndex> {
        let buffer = calculateTileBuffer(forPadding: paddingMeters, boundingBox: geometry.bbox, zoom: zoom)
        return tiles(for: geometry, zoom: zoom, buffer: buffer)
    }

    // Resolves tiles for any geometry type
    internal static func tiles(
        for geometry: MTOfflineRegionGeometry,
        zoom: Int,
        buffer: Int = 1
    ) -> Set<MTTileIndex> {
        switch geometry {
        case .boundingBox(let box):
            let bounds = tileBounds(for: box, zoom: zoom, buffer: buffer)
            var result = Set<MTTileIndex>()
            for x in bounds.minX...bounds.maxX {
                for y in bounds.minY...bounds.maxY {
                    result.insert(MTTileIndex(x: x, y: y, z: zoom))
                }
            }
            return result
        case .route(let coordinates):
            return tiles(for: coordinates, zoom: zoom, buffer: buffer)
        case .polygon(let coordinates):
            return tiles(forPolygon: coordinates, zoom: zoom, buffer: buffer)
        }
    }
}

// MARK: - Estimation and Ranges
extension MTTileMath {
    // Computes the exact total number of tiles required to cover a geometry over a range of zooms.
    internal static func estimateTileCount(
        for geometry: MTOfflineRegionGeometry,
        zoomRange: MTOfflineZoomRange,
        paddingMeters: Double?
    ) -> Int {
        switch geometry {
        case .boundingBox(let bbox):
            return estimateTileCount(for: bbox, zoomRange: zoomRange, paddingMeters: paddingMeters)
        default:
            var totalTiles = 0
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                let buffer = calculateTileBuffer(forPadding: paddingMeters, boundingBox: geometry.bbox, zoom: zoom)
                totalTiles += tiles(for: geometry, zoom: zoom, buffer: buffer).count
            }
            return totalTiles
        }
    }

    // Computes the exact total number of tiles required to cover a geometry over a range of zooms.
    internal static func estimateTileCount(
        for geometry: MTOfflineRegionGeometry,
        zoomRange: MTOfflineZoomRange,
        buffer: Int = 1
    ) -> Int {
        switch geometry {
        case .boundingBox(let bbox):
            return estimateTileCount(for: bbox, zoomRange: zoomRange, buffer: buffer)
        default:
            var totalTiles = 0
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                totalTiles += tiles(for: geometry, zoom: zoom, buffer: buffer).count
            }
            return totalTiles
        }
    }

    // Computes the exact total number of tiles required to cover a bounding box over a range of zooms.
    internal static func estimateTileCount(
        for bbox: MTBoundingBox,
        zoomRange: MTOfflineZoomRange,
        paddingMeters: Double?
    ) -> Int {
        let normalizedBoxes = bbox.normalizedAndSplit()
        var totalTiles = 0

        for box in normalizedBoxes {
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                let buffer = calculateTileBuffer(forPadding: paddingMeters, boundingBox: box, zoom: zoom)
                let bounds = tileBounds(for: box, zoom: zoom, buffer: buffer)
                let countX = bounds.maxX - bounds.minX + 1
                let countY = bounds.maxY - bounds.minY + 1
                totalTiles += countX * countY
            }
        }
        return totalTiles
    }

    // Computes the exact total number of tiles required to cover a bounding box over a range of zooms.
    internal static func estimateTileCount(
        for bbox: MTBoundingBox,
        zoomRange: MTOfflineZoomRange,
        buffer: Int = 1
    ) -> Int {
        let normalizedBoxes = bbox.normalizedAndSplit()
        var totalTiles = 0

        for box in normalizedBoxes {
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                let bounds = tileBounds(for: box, zoom: zoom, buffer: buffer)
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
        zoomRange: MTOfflineZoomRange,
        paddingMeters: Double?
    ) -> [Int: Int] {
        let normalizedBoxes = bbox.normalizedAndSplit()
        var counts: [Int: Int] = [:]

        for box in normalizedBoxes {
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                let buffer = calculateTileBuffer(forPadding: paddingMeters, boundingBox: box, zoom: zoom)
                let bounds = tileBounds(for: box, zoom: zoom, buffer: buffer)
                let countX = bounds.maxX - bounds.minX + 1
                let countY = bounds.maxY - bounds.minY + 1
                counts[zoom, default: 0] += countX * countY
            }
        }
        return counts
    }

    // Computes the exact number of tiles required per zoom level.
    internal static func estimateTileCountPerZoom(
        for bbox: MTBoundingBox,
        zoomRange: MTOfflineZoomRange,
        buffer: Int = 1
    ) -> [Int: Int] {
        let normalizedBoxes = bbox.normalizedAndSplit()
        var counts: [Int: Int] = [:]

        for box in normalizedBoxes {
            for zoom in zoomRange.minZoom...zoomRange.maxZoom {
                let bounds = tileBounds(for: box, zoom: zoom, buffer: buffer)
                let countX = bounds.maxX - bounds.minX + 1
                let countY = bounds.maxY - bounds.minY + 1
                counts[zoom, default: 0] += countX * countY
            }
        }
        return counts
    }

    // Calculates the closed ranges of X and Y tile coordinates for a given bounding box and zoom level.
    internal static func tileRanges(
        for bbox: MTBoundingBox,
        zoom: Int,
        paddingMeters: Double?
    ) -> (x: ClosedRange<Int>, y: ClosedRange<Int>) {
        let buffer = calculateTileBuffer(forPadding: paddingMeters, boundingBox: bbox, zoom: zoom)
        let bounds = tileBounds(for: bbox, zoom: zoom, buffer: buffer)
        return (x: bounds.minX...bounds.maxX, y: bounds.minY...bounds.maxY)
    }

    // Calculates the closed ranges of X and Y tile coordinates for a given bounding box and zoom level.
    internal static func tileRanges(
        for bbox: MTBoundingBox,
        zoom: Int,
        buffer: Int = 1
    ) -> (x: ClosedRange<Int>, y: ClosedRange<Int>) {
        let bounds = tileBounds(for: bbox, zoom: zoom, buffer: buffer)
        return (x: bounds.minX...bounds.maxX, y: bounds.minY...bounds.maxY)
    }

    // Calculates the closed ranges of X and Y tile coordinates for a given bounding box and a range of zoom levels.
    internal static func tileRanges(
        for bbox: MTBoundingBox,
        zoomRange: ClosedRange<Int>,
        paddingMeters: Double?
    ) -> [Int: (x: ClosedRange<Int>, y: ClosedRange<Int>)] {
        var result = [Int: (x: ClosedRange<Int>, y: ClosedRange<Int>)]()
        for z in zoomRange {
            result[z] = tileRanges(for: bbox, zoom: z, paddingMeters: paddingMeters)
        }
        return result
    }

    // Calculates the closed ranges of X and Y tile coordinates for a given bounding box and a range of zoom levels.
    internal static func tileRanges(
        for bbox: MTBoundingBox,
        zoomRange: ClosedRange<Int>,
        buffer: Int = 1
    ) -> [Int: (x: ClosedRange<Int>, y: ClosedRange<Int>)] {
        var result = [Int: (x: ClosedRange<Int>, y: ClosedRange<Int>)]()
        for z in zoomRange {
            result[z] = tileRanges(for: bbox, zoom: z, buffer: buffer)
        }
        return result
    }
}
