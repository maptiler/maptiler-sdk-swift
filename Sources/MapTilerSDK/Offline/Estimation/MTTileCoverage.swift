//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTileCoverage.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation

// A horizontal band of tile rows that share the same set of covered columns.
internal struct MTTileBand: Equatable, Sendable {
    // The inclusive range of tile rows (Y, XYZ scheme) covered by the band.
    let rows: ClosedRange<Int>
    // Sorted, non-overlapping, non-adjacent inclusive ranges of tile columns (X).
    let columns: [ClosedRange<Int>]

    var tileCount: Int {
        rows.count * columns.reduce(0) { $0 + $1.count }
    }
}

// The set of tiles covering a geometry at a single zoom level.
//
// Tiles are stored as row bands of column intervals rather than as individual tiles, so very large
// regions can be counted without materializing every tile. The covered tiles are identical to the ones
// produced by the set-based helpers in `MTTileMath`, which remain the reference implementation.
internal struct MTTileCoverage: Equatable, Sendable {
    let zoom: Int
    // Bands sorted by row, never overlapping each other.
    let bands: [MTTileBand]

    var tileCount: Int {
        bands.reduce(0) { $0 + $1.tileCount }
    }

    // Calls `body` for every covered tile, ordered by row and then by column.
    func forEachTile(_ body: (_ x: Int, _ y: Int) -> Void) {
        for band in bands {
            for y in band.rows {
                for columns in band.columns {
                    for x in columns {
                        body(x, y)
                    }
                }
            }
        }
    }

    // Counts covered tiles per ancestor tile at `ancestorZoom` (which must not exceed `zoom`),
    // splitting bands and column ranges at ancestor boundaries instead of visiting each tile.
    func tileCountsByAncestor(atZoom ancestorZoom: Int) -> [MTTileIndex: Int] {
        let shift = zoom - ancestorZoom
        let size = 1 << shift
        var counts: [MTTileIndex: Int] = [:]

        for band in bands {
            var rowStart = band.rows.lowerBound
            while rowStart <= band.rows.upperBound {
                let ancestorY = rowStart >> shift
                let rowEnd = Swift.min(band.rows.upperBound, (ancestorY + 1) * size - 1)
                let height = rowEnd - rowStart + 1

                for columns in band.columns {
                    var columnStart = columns.lowerBound
                    while columnStart <= columns.upperBound {
                        let ancestorX = columnStart >> shift
                        let columnEnd = Swift.min(columns.upperBound, (ancestorX + 1) * size - 1)
                        let ancestor = MTTileIndex(x: ancestorX, y: ancestorY, z: ancestorZoom)
                        counts[ancestor, default: 0] += height * (columnEnd - columnStart + 1)
                        columnStart = columnEnd + 1
                    }
                }
                rowStart = rowEnd + 1
            }
        }
        return counts
    }

    // Returns all covered tiles. Intended for tests and small regions only.
    func tileIndices() -> Set<MTTileIndex> {
        var result = Set<MTTileIndex>()
        forEachTile { x, y in result.insert(MTTileIndex(x: x, y: y, z: zoom)) }
        return result
    }
}

// MARK: - Building coverage

extension MTTileCoverage {
    // Computes the tiles the offline planner downloads for a geometry at one zoom level.
    //
    // Bounding boxes are normalized and split at the antimeridian, each part padded by its own buffer,
    // and overlapping parts are merged so that no tile is counted twice. Routes and polygons are padded by
    // a tile buffer derived from `paddingMeters` and the geometry's bounding box.
    static func make(
        for geometry: MTOfflineRegionGeometry,
        zoom: Int,
        paddingMeters: Double?
    ) -> MTTileCoverage {
        switch geometry {
        case .boundingBox(let bbox):
            let rectangles = bbox.normalizedAndSplit().map { box in
                let buffer = MTTileMath.calculateTileBuffer(forPadding: paddingMeters, boundingBox: box, zoom: zoom)
                return MTTileMath.tileBounds(for: box, zoom: zoom, buffer: buffer)
            }
            return union(of: rectangles, zoom: zoom)
        case .route(let coordinates):
            let buffer = MTTileMath.calculateTileBuffer(
                forPadding: paddingMeters,
                boundingBox: geometry.bbox,
                zoom: zoom
            )
            return MTTileCoverage(zoom: zoom, rows: routeRows(coordinates, zoom: zoom), buffer: buffer)
        case .polygon(let coordinates):
            let buffer = MTTileMath.calculateTileBuffer(
                forPadding: paddingMeters,
                boundingBox: geometry.bbox,
                zoom: zoom
            )
            let rows = coordinates.count > 2
                ? polygonRows(coordinates, zoom: zoom)
                : routeRows(coordinates, zoom: zoom)
            return MTTileCoverage(zoom: zoom, rows: rows, buffer: buffer)
        }
    }

    // Merges possibly overlapping tile rectangles into disjoint bands.
    static func union(of rectangles: [MTTileMath.MTTileBounds], zoom: Int) -> MTTileCoverage {
        let boundaries = Set(rectangles.flatMap { [$0.minY, $0.maxY + 1] }).sorted()
        var bands: [MTTileBand] = []

        for index in 0..<Swift.max(0, boundaries.count - 1) {
            let rows = boundaries[index]...(boundaries[index + 1] - 1)
            let columns = rectangles
                .filter { $0.minY <= rows.lowerBound && $0.maxY >= rows.upperBound }
                .map { $0.minX...$0.maxX }
            let merged = mergeRanges(columns)
            if !merged.isEmpty {
                bands.append(MTTileBand(rows: rows, columns: merged))
            }
        }
        return MTTileCoverage(zoom: zoom, bands: bands)
    }

    // Builds a coverage from per-row column ranges, dilating it by `buffer` tiles in every direction
    // (clamped to the valid tile range), which matches `MTTileMath.applyBuffer`.
    init(zoom: Int, rows: [Int: [ClosedRange<Int>]], buffer: Int) {
        let maxIndex = MTTileMath.safeMaxTile(for: zoom)
        var dilated: [Int: [ClosedRange<Int>]] = [:]

        if buffer > 0 {
            for (y, columns) in rows {
                let expanded = columns.map {
                    Swift.max(0, $0.lowerBound - buffer)...Swift.min(maxIndex, $0.upperBound + buffer)
                }
                for row in Swift.max(0, y - buffer)...Swift.min(maxIndex, y + buffer) {
                    dilated[row, default: []].append(contentsOf: expanded)
                }
            }
        } else {
            dilated = rows
        }

        let bands = dilated.keys.sorted().compactMap { y -> MTTileBand? in
            let merged = MTTileCoverage.mergeRanges(dilated[y] ?? [])
            return merged.isEmpty ? nil : MTTileBand(rows: y...y, columns: merged)
        }
        self.init(zoom: zoom, bands: bands)
    }

    // Sorts ranges and merges the ones that overlap or touch.
    static func mergeRanges(_ ranges: [ClosedRange<Int>]) -> [ClosedRange<Int>] {
        let sorted = ranges.sorted { $0.lowerBound < $1.lowerBound }
        var merged: [ClosedRange<Int>] = []
        for range in sorted {
            if let last = merged.last, range.lowerBound <= last.upperBound + 1 {
                merged[merged.count - 1] = last.lowerBound...Swift.max(last.upperBound, range.upperBound)
            } else {
                merged.append(range)
            }
        }
        return merged
    }
}

// MARK: - Routes and polygons

extension MTTileCoverage {
    // Tiles touched by a route before buffering, grouped by row. Mirrors `MTTileMath.tiles(for:zoom:buffer:)`.
    static func routeRows(_ route: [CLLocationCoordinate2D], zoom: Int) -> [Int: [ClosedRange<Int>]] {
        guard !route.isEmpty else { return [:] }

        if route.count == 1 {
            let x = MTTileMath.longitudeToTileX(lon: route[0].longitude, zoom: zoom)
            let y = MTTileMath.latitudeToTileY(lat: route[0].latitude, zoom: zoom)
            return [y: [x...x]]
        }

        var rows: [Int: [ClosedRange<Int>]] = [:]
        let zoomDouble = Double(Swift.max(0, Swift.min(zoom, 62)))
        for i in 0..<(route.count - 1) {
            let p1 = route[i]
            let p2 = route[i + 1]

            let x1 = MTMath.longitudeToTileX(longitude: p1.longitude, zoom: zoomDouble, round: false)
            let y1 = MTMath.latitudeToTileY(latitude: p1.latitude, zoom: zoomDouble, round: false)
            let x2 = MTMath.longitudeToTileX(longitude: p2.longitude, zoom: zoomDouble, round: false)
            let y2 = MTMath.latitudeToTileY(latitude: p2.latitude, zoom: zoomDouble, round: false)

            for tile in MTTileMath.tilesIntersectingSegment(p1: (x: x1, y: y1), p2: (x: x2, y: y2), zoom: zoom) {
                rows[tile.y, default: []].append(tile.x...tile.x)
            }
        }
        return rows
    }

    // Tiles covered by a polygon before buffering, grouped by row. Mirrors `MTTileMath.tiles(forPolygon:zoom:buffer:)`:
    // the tiles crossed by the outline plus every tile in the polygon's bounds whose center lies inside it.
    //
    // Instead of testing each tile center, each row computes where the outline crosses the row's center latitude
    // and derives the inside column ranges from those crossings, using the same arithmetic as the point test.
    static func polygonRows(_ polygon: [CLLocationCoordinate2D], zoom: Int) -> [Int: [ClosedRange<Int>]] {
        var closedPolygon = polygon
        if let first = closedPolygon.first, let last = closedPolygon.last,
            first.latitude != last.latitude || first.longitude != last.longitude {
            closedPolygon.append(first)
        }

        var rows = routeRows(closedPolygon, zoom: zoom)

        let bounds = MTTileMath.tileBounds(for: MTBoundingBox(from: polygon), zoom: zoom, buffer: 0)
        let columns = bounds.minX...bounds.maxX
        let n = pow(2.0, Double(zoom))
        let centerLongitude = { (x: Int) -> Double in (Double(x) + 0.5) / n * 360.0 - 180.0 }

        for y in bounds.minY...bounds.maxY {
            let latRad = atan(sinh(.pi * (1.0 - 2.0 * (Double(y) + 0.5) / n)))
            let lat = latRad * 180.0 / .pi

            var crossings: [Double] = []
            var j = closedPolygon.count - 1
            for i in 0..<closedPolygon.count {
                let pi = closedPolygon[i]
                let pj = closedPolygon[j]
                if (pi.latitude > lat) != (pj.latitude > lat) {
                    crossings.append((pj.longitude - pi.longitude) * (lat - pi.latitude) /
                        (pj.latitude - pi.latitude) + pi.longitude)
                }
                j = i
            }
            crossings.sort()

            // A center longitude `c` is inside when an odd number of crossings lie strictly east of it.
            // Between crossings[t - 1] (inclusive) and crossings[t] (exclusive) that number is `count - t`.
            let count = crossings.count
            for t in 0...count where (count - t) % 2 == 1 {
                let lower = t == 0 ? -Double.infinity : crossings[t - 1]
                let upper = t == count ? Double.infinity : crossings[t]
                guard let firstX = firstIndex(in: columns, where: { centerLongitude($0) >= lower }) else { continue }
                let endX = firstIndex(in: columns) { centerLongitude($0) >= upper } ?? columns.upperBound + 1
                if firstX < endX {
                    rows[y, default: []].append(firstX...(endX - 1))
                }
            }
        }
        return rows
    }

    // Binary search for the first index in `range` satisfying a predicate that is monotonic over the range.
    private static func firstIndex(in range: ClosedRange<Int>, where predicate: (Int) -> Bool) -> Int? {
        var low = range.lowerBound
        var high = range.upperBound + 1
        while low < high {
            let mid = low + (high - low) / 2
            if predicate(mid) {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low <= range.upperBound ? low : nil
    }
}
