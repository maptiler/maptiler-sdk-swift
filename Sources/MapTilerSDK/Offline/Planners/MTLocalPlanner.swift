//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLocalPlanner.swift
//  MapTilerSDK
//

import Foundation

// A minimal stub implementation of the MTOfflinePlanner interface.
internal class MTLocalPlanner: MTOfflinePlanner {

    // The URLSession used for network requests during planning.
    private let session: URLSession

    // Initializes a new planner with dependency injection.
    internal init(session: URLSession = MTConfig.sharedURLSession) {
        self.session = session
    }

    internal func estimate(for definition: MTOfflineRegionDefinition) async throws -> MTTileEstimate {
        try validate(definition: definition)

        let estimator = MTOfflineEstimator()
        let stats = try await estimator.estimatePack(region: definition)

        let globalLimit = MTOfflineConfiguration.shared.effectiveGlobalLimit
        let packLimit = definition.maxTileCount ?? Int.max
        let effectiveLimit = min(globalLimit, packLimit)

        if stats.resourceCount > effectiveLimit {
            throw MTOfflineError.exceedsMaximumTileCount(limit: effectiveLimit, requested: stats.resourceCount)
        }

        return MTTileEstimate(stats: stats)
    }

    internal func generateManifest(for definition: MTOfflineRegionDefinition) async throws -> MTManifest {
        try validate(definition: definition)

        let isFlexible = {
            if case .boundingBox = definition.geometry { return false }
            return true
        }()
        let paddingMeters = definition.padding ?? (isFlexible ? 2000.0 : nil)

        // For non-rectangular geometries, slightly pad the bounding box stored in the manifest.
        // MapLibre uses this manifest bbox to aggressively clip rendering. Without padding,
        // tiles on the exact edges of a route or polygon won't be drawn.
        var manifestBbox = definition.bbox
        if let pad = paddingMeters, pad > 0, isFlexible {
            manifestBbox = manifestBbox.expanded(byMeters: pad)
        }

        let metadata = MTManifestMetadata(
            referenceStyle: definition.referenceStyle,
            styleVariant: definition.styleVariant,
            bbox: manifestBbox,
            minZoom: definition.minZoom,
            maxZoom: definition.maxZoom,
            pixelRatio: definition.pixelRatio,
            isTerrainEnabled: definition.isTerrainEnabled
        )

        let resolvedStyle = try await resolveStyleAndDependencies(for: definition)

        let tileResources = try await generateTileResources(
            geometry: definition.geometry,
            minZoom: definition.minZoom,
            maxZoom: definition.maxZoom,
            paddingMeters: paddingMeters,
            dependencies: resolvedStyle?.dependencies
        )

        let glyphResources = try await generateGlyphResources(dependencies: resolvedStyle?.dependencies)
        let spriteResources = try await generateSpriteResources(dependencies: resolvedStyle?.dependencies)

        // Accurate total resource count check
        var totalCount = tileResources.count + glyphResources.count + spriteResources.count
        if resolvedStyle != nil { totalCount += 1 }

        let globalLimit = MTOfflineConfiguration.shared.effectiveGlobalLimit
        let packLimit = definition.maxTileCount ?? Int.max
        let effectiveLimit = min(globalLimit, packLimit)

        if totalCount > effectiveLimit {
            throw MTOfflineError.exceedsMaximumTileCount(limit: effectiveLimit, requested: totalCount)
        }

        let manifest = MTManifest(
            metadata: metadata,
            style: resolvedStyle?.resource,
            tiles: tileResources,
            glyphs: glyphResources,
            sprites: spriteResources
        )

        // Ensure the pack actually contains data.
        // If 0 tiles were found, the area/zoom combination is likely invalid or too small.
        guard !manifest.tiles.isEmpty else {
            throw MTOfflineError.invalidRegion
        }

        return manifest
    }

    // Resolves the style URL and its dependencies, injecting terrain sources if necessary.
    private func resolveStyleAndDependencies(
        for definition: MTOfflineRegionDefinition
    ) async throws -> (resource: MTMapResource, dependencies: MTStyleDependencies)? {
        var resolvedStyle: (resource: MTMapResource, dependencies: MTStyleDependencies)?
        if case .custom(let customURL) = definition.referenceStyle {
            // For custom styles we still just use the URL
            resolvedStyle = try await resolveStyle(url: customURL)
        } else {
            guard let key = await MTConfig.shared.getAPIKey() else {
                throw MTOfflinePackError.unauthorized
            }
            guard let styleURL = definition.referenceStyle.fetchStyleURL(
                variant: definition.styleVariant,
                apiKey: key
            ) else {
                throw MTOfflinePackError.invalidZoomRange // Generic mapId failure fallback
            }
            resolvedStyle = try await resolveStyle(url: styleURL)
        }

        if definition.isTerrainEnabled, let currentDependencies = resolvedStyle?.dependencies {
            if !currentDependencies.sources.contains(where: { $0.type == "raster-dem" }) {
                let apiKey = await MTConfig.shared.getAPIKey() ?? ""
                let terrainSource = MTStyleSource(
                    id: "maptiler-terrain",
                    type: "raster-dem",
                    url: "https://api.maptiler.com/tiles/terrain-rgb-v2/tiles.json?key=\(apiKey)"
                )

                var newSources = currentDependencies.sources
                newSources.append(terrainSource)

                let updatedDependencies = MTStyleDependencies(
                    sprites: currentDependencies.sprites,
                    glyphsTemplate: currentDependencies.glyphsTemplate,
                    sources: newSources,
                    fontStacks: currentDependencies.fontStacks
                )
                resolvedStyle?.dependencies = updatedDependencies
            }
        }

        return resolvedStyle
    }

    // Validates the initial parameters to fail fast if they are malformed or invalid.
    private func validate(definition: MTOfflineRegionDefinition) throws {
        guard definition.minZoom >= 0, definition.maxZoom <= 22, definition.minZoom <= definition.maxZoom else {
            throw MTOfflinePackError.invalidZoomRange
        }

        // swiftlint:disable all
        // Ensure coordinates are within standard WGS84 bounds (longitude -180..180, latitude within Web Mercator limits)
        let bbox = definition.bbox
        guard bbox.minLat >= -85.051129,
             bbox.maxLat <= 85.051129,
             bbox.minLon >= -180,
             bbox.maxLon <= 180,
             bbox.minLat <= bbox.maxLat else {
            throw MTOfflinePackError.invalidBoundingBox
        }
        // swiftlint:enable all
    }
}

// MARK: - Helpers
extension MTLocalPlanner {
    private func resolveStyle(url: URL) async throws -> (MTMapResource, MTStyleDependencies) {
        let normalizedURL = await MTURLNormalizer.normalize(url: url)
        let (data, response) = try await session.data(from: normalizedURL)

        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode || httpResponse.statusCode == 204 else {
            throw MTOfflinePackError.networkError(URLError(.badServerResponse))
        }

        let resource = MTMapResource(url: url, destinationPath: "style.json")
        let parser = MTStyleParser()
        let dependencies = try parser.extractDependencies(from: data)
        return (resource, dependencies)
    }

    private func generateTileResources(
        geometry: MTOfflineRegionGeometry,
        minZoom: Int,
        maxZoom: Int,
        paddingMeters: Double?,
        dependencies: MTStyleDependencies?
    ) async throws -> [MTMapResource] {
        guard let sources = dependencies?.sources else { return [] }
        var resources: [MTMapResource] = []

        for source in sources {
            let resolved = try await resolveTemplateURL(for: source)
            let template = resolved.template

            // Intersect requested zoom with source zoom limits
            var effMin = Swift.max(minZoom, resolved.minZoom)
            var effMax = Swift.min(maxZoom, resolved.maxZoom)

            // Overzoom support: if requested minZoom is above source maxZoom, 
            // we download the source maxZoom tiles to allow engine overzooming.
            if minZoom > resolved.maxZoom {
                effMin = resolved.maxZoom
                effMax = resolved.maxZoom
            }

            guard effMin <= effMax else { continue }

            let ext = detectExtension(from: template)
            let effRange = effMin...effMax

            if case .boundingBox(let bbox) = geometry {
                let splitBoxes = bbox.normalizedAndSplit()
                for box in splitBoxes {
                    let rangesByZoom = MTTileMath.tileRanges(
                        for: box,
                        zoomRange: effRange,
                        paddingMeters: paddingMeters
                    )

                    let sourceResources = createResources(
                        for: source,
                        template: template,
                        ext: ext,
                        rangesByZoom: rangesByZoom,
                        zoomRange: effRange
                    )
                    resources.append(contentsOf: sourceResources)
                }
            } else {
                var geometryTiles = Set<MTTileIndex>()
                for zoom in effRange {
                    geometryTiles.formUnion(MTTileMath.tiles(for: geometry, zoom: zoom, paddingMeters: paddingMeters))
                }
                let sourceResources = createResources(
                    for: source,
                    template: template,
                    ext: ext,
                    tiles: geometryTiles
                )
                resources.append(contentsOf: sourceResources)
            }
        }
        return resources
    }

    private struct MTTemplateInfo {
        let template: String
        let minZoom: Int
        let maxZoom: Int
    }

    private func resolveTemplateURL(for source: MTStyleSource) async throws -> MTTemplateInfo {
        let sourceMin = source.minZoom ?? 0
        let sourceMax = source.maxZoom ?? 22

        if let tiles = source.tiles, let first = tiles.first {
            return MTTemplateInfo(template: first, minZoom: sourceMin, maxZoom: sourceMax)
        }

        guard let urlStr = source.url, let url = URL(string: urlStr) else {
            throw MTOfflineError.networkError(URLError(.badURL))
        }

        let normalizedURL = await MTURLNormalizer.normalize(url: url)

        // Fetch TileJSON
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: normalizedURL)
        } catch let urlError as URLError {
            throw MTOfflineError.networkError(urlError)
        } catch {
            throw MTOfflineError.networkError(URLError(.unknown))
        }

        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode || httpResponse.statusCode == 204 else {
            throw MTOfflineError.networkError(URLError(.badServerResponse))
        }

        guard let tileJSON = try? JSONDecoder().decode(MTTileJSON.self, from: data) else {
            throw MTOfflineError.networkError(URLError(.cannotParseResponse))
        }

        guard let template = tileJSON.preferredTileURLTemplate else {
            throw MTOfflineError.networkError(URLError(.cannotParseResponse))
        }
        // TileJSON zoom limits take precedence over style source limits if present
        let finalMin = tileJSON.minzoom
        let finalMax = tileJSON.maxzoom

        return MTTemplateInfo(template: template, minZoom: finalMin, maxZoom: finalMax)
    }

    private func detectExtension(from template: String) -> String {
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

    private func createResources(
        for source: MTStyleSource,
        template: String,
        ext: String,
        rangesByZoom: [Int: (x: ClosedRange<Int>, y: ClosedRange<Int>)],
        zoomRange: ClosedRange<Int>
    ) -> [MTMapResource] {
        var resources: [MTMapResource] = []
        for z in zoomRange {
            guard let ranges = rangesByZoom[z] else { continue }
            for x in ranges.x {
                for y in ranges.y {
                    let resolvedY = template.contains("{-y}") ? MTTileMath.flipYCoordinate(y: y, zoom: z) : y
                    let tileUrlStr = template
                        .replacingOccurrences(of: "{z}", with: "\(z)")
                        .replacingOccurrences(of: "{x}", with: "\(x)")
                        .replacingOccurrences(of: "{y}", with: "\(resolvedY)")
                        .replacingOccurrences(of: "{-y}", with: "\(resolvedY)")

                    if let tileUrl = URL(string: tileUrlStr) {
                        let destPath = "tiles/\(source.id)/\(z)/\(x)/\(y).\(ext)"
                        resources.append(MTMapResource(url: tileUrl, destinationPath: destPath))
                    }
                }
            }
        }
        return resources
    }

    private func createResources(
        for source: MTStyleSource,
        template: String,
        ext: String,
        tiles: Set<MTTileIndex>
    ) -> [MTMapResource] {
        var resources: [MTMapResource] = []
        for tile in tiles {
            let z = tile.z
            let x = tile.x
            let y = tile.y
            let resolvedY = template.contains("{-y}") ? MTTileMath.flipYCoordinate(y: y, zoom: z) : y
            let tileUrlStr = template
                .replacingOccurrences(of: "{z}", with: "\(z)")
                .replacingOccurrences(of: "{x}", with: "\(x)")
                .replacingOccurrences(of: "{y}", with: "\(resolvedY)")
                .replacingOccurrences(of: "{-y}", with: "\(resolvedY)")

            if let tileUrl = URL(string: tileUrlStr) {
                let destPath = "tiles/\(source.id)/\(z)/\(x)/\(y).\(ext)"
                resources.append(MTMapResource(url: tileUrl, destinationPath: destPath))
            }
        }
        return resources
    }

    private func generateGlyphResources(dependencies: MTStyleDependencies?) async throws -> [MTMapResource] {
        guard let template = dependencies?.glyphsTemplate,
            let fontStacks = dependencies?.fontStacks, !fontStacks.isEmpty else {
            return []
        }

        var resources: [MTMapResource] = []
        let ranges = MTGlyphHelper.generateRanges()

        for fontStack in fontStacks {
            let fontStackStr = fontStack.joined(separator: ",")
            for range in ranges {
                let urlStr = MTGlyphHelper.format(template: template, fontStack: fontStackStr, range: range.description)
                if let url = URL(string: urlStr) {
                    let destPath = "glyphs/\(fontStackStr)/\(range.description).pbf"
                    resources.append(MTMapResource(url: url, destinationPath: destPath))
                }
            }
        }

        return resources
    }

    private func generateSpriteResources(dependencies: MTStyleDependencies?) async throws -> [MTMapResource] {
        guard let sprites = dependencies?.sprites else { return [] }
        var resources: [MTMapResource] = []
        for sprite in sprites {
            // we should fetch sprite.json and sprite.png (and possibly @2x)
            let baseURLStr = sprite.url.absoluteString

            // JSON
            let jsonURLStr = baseURLStr + ".json"
            let jsonDest = sprite.id == "default" ? "sprite.json" : "sprite-\(sprite.id).json"
            if let jsonURL = URL(string: jsonURLStr) {
                resources.append(MTMapResource(url: jsonURL, destinationPath: jsonDest))
            }

            // PNG
            let pngURLStr = baseURLStr + ".png"
            let pngDest = sprite.id == "default" ? "sprite.png" : "sprite-\(sprite.id).png"
            if let pngURL = URL(string: pngURLStr) {
                resources.append(MTMapResource(url: pngURL, destinationPath: pngDest))
            }

            // @2x JSON
            let json2xURLStr = baseURLStr + "@2x.json"
            let json2xDest = sprite.id == "default" ? "sprite@2x.json" : "sprite-\(sprite.id)@2x.json"
            if let json2xURL = URL(string: json2xURLStr) {
                resources.append(MTMapResource(url: json2xURL, destinationPath: json2xDest))
            }

            // @2x PNG
            let png2xURLStr = baseURLStr + "@2x.png"
            let png2xDest = sprite.id == "default" ? "sprite@2x.png" : "sprite-\(sprite.id)@2x.png"
            if let png2xURL = URL(string: png2xURLStr) {
                resources.append(MTMapResource(url: png2xURL, destinationPath: png2xDest))
            }
        }
        return resources
    }
}
