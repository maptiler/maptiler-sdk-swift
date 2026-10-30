//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineResourcePlan.swift
//  MapTilerSDK
//

import Foundation

// The resources an offline pack downloads for a region, derived from resolved style metadata
// without any network access. The estimator counts it and the planner turns it into a manifest,
// so estimates always match what is actually downloaded.
internal struct MTOfflineResourcePlan {
    // The tiles planned for a single source.
    struct SourcePlan {
        let source: MTOfflineSourceMetadata
        let zoomRange: ClosedRange<Int>
        let coverages: [MTTileCoverage]

        var tileCount: Int {
            coverages.reduce(0) { $0 + $1.tileCount }
        }
    }

    // Requests per sprite (JSON and PNG, at 1x and 2x).
    static let filesPerSprite = 4

    let definition: MTOfflineRegionDefinition
    let metadata: MTOfflineStyleMetadata
    let sources: [SourcePlan]

    var tileCount: Int {
        sources.reduce(0) { $0 + $1.tileCount }
    }

    var glyphCount: Int {
        guard metadata.glyphsTemplate != nil else { return 0 }
        return metadata.fontStacks.count * definition.glyphRanges.rangeStarts.count
    }

    var spriteCount: Int {
        metadata.sprites.count * MTOfflineResourcePlan.filesPerSprite
    }

    let styleCount = 1

    var resourceCount: Int {
        tileCount + glyphCount + spriteCount + styleCount
    }

    // The resource limit that applies to the region: the global limit or the region's own, whichever is lower.
    var resourceLimit: Int {
        Swift.min(MTOfflineConfiguration.shared.effectiveGlobalLimit, definition.maxTileCount ?? Int.max)
    }

    init(definition: MTOfflineRegionDefinition, metadata: MTOfflineStyleMetadata) throws {
        try definition.validateForOffline()

        var sourceList = metadata.sources
        if definition.isTerrainEnabled, !sourceList.contains(where: { $0.type == .rasterDEM }) {
            guard let terrainSource = metadata.terrainSource else {
                throw MTOfflineError.missingKey("terrainSource")
            }
            sourceList.append(terrainSource)
        }

        // Coverage depends only on geometry and zoom, so it is shared between sources.
        var coverageByZoom: [Int: MTTileCoverage] = [:]
        let paddingMeters = definition.effectivePaddingMeters

        self.sources = sourceList.compactMap { source in
            guard let zoomRange = MTOfflineResourcePlan.effectiveZoomRange(
                minZoom: definition.minZoom,
                maxZoom: definition.maxZoom,
                sourceMinZoom: source.minZoom,
                sourceMaxZoom: source.maxZoom
            ) else {
                return nil
            }

            let coverages = zoomRange.map { zoom in
                if let cached = coverageByZoom[zoom] { return cached }
                let coverage = MTTileCoverage.make(for: definition.geometry, zoom: zoom, paddingMeters: paddingMeters)
                coverageByZoom[zoom] = coverage
                return coverage
            }
            return SourcePlan(source: source, zoomRange: zoomRange, coverages: coverages)
        }
        self.definition = definition
        self.metadata = metadata
    }

    // Intersects the requested zoom range with the source's. When the request starts above the source's
    // maximum zoom, the source's maximum zoom is downloaded so the map can overzoom it.
    static func effectiveZoomRange(
        minZoom: Int,
        maxZoom: Int,
        sourceMinZoom: Int,
        sourceMaxZoom: Int
    ) -> ClosedRange<Int>? {
        if minZoom > sourceMaxZoom {
            return sourceMaxZoom...sourceMaxZoom
        }
        let effectiveMin = Swift.max(minZoom, sourceMinZoom)
        let effectiveMax = Swift.min(maxZoom, sourceMaxZoom)
        return effectiveMin <= effectiveMax ? effectiveMin...effectiveMax : nil
    }
}

// MARK: - Manifest resources

extension MTOfflineResourcePlan {
    func tileResources() -> [MTMapResource] {
        var resources: [MTMapResource] = []
        resources.reserveCapacity(tileCount)

        for sourcePlan in sources {
            let template = sourcePlan.source.tileURLTemplate
            let ext = MTOfflineResourcePlan.detectExtension(from: template)
            let isTMS = template.contains("{-y}")

            for coverage in sourcePlan.coverages {
                let z = coverage.zoom
                coverage.forEachTile { x, y in
                    let resolvedY = isTMS ? MTTileMath.flipYCoordinate(y: y, zoom: z) : y
                    let tileURLString = template
                        .replacingOccurrences(of: "{z}", with: "\(z)")
                        .replacingOccurrences(of: "{x}", with: "\(x)")
                        .replacingOccurrences(of: "{y}", with: "\(resolvedY)")
                        .replacingOccurrences(of: "{-y}", with: "\(resolvedY)")

                    if let tileURL = URL(string: tileURLString) {
                        let destinationPath = "tiles/\(sourcePlan.source.id)/\(z)/\(x)/\(y).\(ext)"
                        resources.append(MTMapResource(url: tileURL, destinationPath: destinationPath))
                    }
                }
            }
        }
        return resources
    }

    func glyphResources() -> [MTMapResource] {
        guard let template = metadata.glyphsTemplate else { return [] }

        var resources: [MTMapResource] = []
        let ranges = definition.glyphRanges.ranges

        for fontStack in metadata.fontStacks {
            let fontStackString = fontStack.joined(separator: ",")
            for range in ranges {
                let urlString = MTGlyphHelper.format(
                    template: template,
                    fontStack: fontStackString,
                    range: range.description
                )
                if let url = URL(string: urlString) {
                    let destinationPath = "glyphs/\(fontStackString)/\(range.description).pbf"
                    resources.append(MTMapResource(url: url, destinationPath: destinationPath))
                }
            }
        }
        return resources
    }

    func spriteResources() -> [MTMapResource] {
        var resources: [MTMapResource] = []
        for sprite in metadata.sprites {
            for variant in ["", "@2x"] {
                for format in [".json", ".png"] {
                    let destinationPath = sprite.id == "default"
                        ? "sprite\(variant)\(format)"
                        : "sprite-\(sprite.id)\(variant)\(format)"
                    if let url = URL(string: sprite.url + variant + format) {
                        resources.append(MTMapResource(url: url, destinationPath: destinationPath))
                    }
                }
            }
        }
        return resources
    }

    static func detectExtension(from template: String) -> String {
        let lower = template.lowercased()
        if lower.contains(".png") {
            return "png"
        } else if lower.contains(".jpg") || lower.contains(".jpeg") {
            return "jpg"
        } else if lower.contains(".webp") {
            return "webp"
        }
        return "pbf"
    }
}

// MARK: - Region helpers

extension MTOfflineRegionDefinition {
    // The padding applied around the geometry. Routes and polygons default to 2000 meters.
    var effectivePaddingMeters: Double? {
        if let padding { return padding }
        if case .boundingBox = geometry { return nil }
        return 2000.0
    }

    // Validates the zoom range and coordinates before planning.
    func validateForOffline() throws {
        guard minZoom >= 0, maxZoom <= 22, minZoom <= maxZoom else {
            throw MTOfflinePackError.invalidZoomRange
        }

        // Ensure coordinates are within standard WGS84 bounds
        // (longitude -180..180, latitude within Web Mercator limits).
        guard bbox.minLat >= -85.051129,
            bbox.maxLat <= 85.051129,
            bbox.minLon >= -180,
            bbox.maxLon <= 180,
            bbox.minLat <= bbox.maxLat else {
            throw MTOfflinePackError.invalidBoundingBox
        }
    }
}
