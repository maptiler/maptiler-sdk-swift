//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineMetadataResolver.swift
//  MapTilerSDK
//

import Foundation

// Resolves the style metadata of a region by fetching its style JSON and source TileJSONs.
//
// Results are cached for a short time, so estimating a pack and then downloading it fetches the style
// and TileJSONs only once. Tiles are never requested here.
internal actor MTOfflineMetadataResolver {
    internal static let shared = MTOfflineMetadataResolver()

    private let session: URLSession
    private let timeToLive: TimeInterval
    private var cache: [String: (metadata: MTOfflineStyleMetadata, resolvedAt: Date)] = [:]

    internal init(session: URLSession = MTConfig.sharedURLSession, timeToLive: TimeInterval = 15 * 60) {
        self.session = session
        self.timeToLive = timeToLive
    }

    internal func metadata(for definition: MTOfflineRegionDefinition) async throws -> MTOfflineStyleMetadata {
        let styleURL = try await resolveStyleURL(for: definition)
        let includeTerrain = definition.isTerrainEnabled
        let cacheKey = "\(styleURL.absoluteString)|terrain=\(includeTerrain)"

        if let cached = cache[cacheKey], Date().timeIntervalSince(cached.resolvedAt) < timeToLive {
            return cached.metadata
        }

        let dependencies = try MTStyleParser().extractDependencies(from: try await fetch(styleURL))

        var sources: [MTOfflineSourceMetadata] = []
        for source in dependencies.sources {
            sources.append(try await resolveSource(source))
        }

        var terrainSource: MTOfflineSourceMetadata?
        if includeTerrain, !sources.contains(where: { $0.type == .rasterDEM }) {
            let apiKey = await MTConfig.shared.getAPIKey() ?? ""
            terrainSource = try await resolveSource(MTStyleSource(
                id: "maptiler-terrain",
                type: "raster-dem",
                url: "\(MTConfig.shared.apiURL)tiles/terrain-rgb-v2/tiles.json?key=\(apiKey)"
            ))
        }

        let metadata = MTOfflineStyleMetadata(
            styleURL: styleURL.absoluteString,
            sources: sources,
            terrainSource: terrainSource,
            glyphsTemplate: dependencies.glyphsTemplate,
            fontStacks: dependencies.fontStacks,
            sprites: dependencies.sprites.map { MTOfflineSpriteMetadata(id: $0.id, url: $0.url.absoluteString) }
        )
        cache[cacheKey] = (metadata, Date())
        return metadata
    }

    private func resolveStyleURL(for definition: MTOfflineRegionDefinition) async throws -> URL {
        if case .custom(let customURL) = definition.referenceStyle {
            return customURL
        }
        guard let key = await MTConfig.shared.getAPIKey() else {
            throw MTOfflinePackError.unauthorized
        }
        let variant = definition.styleVariant
        guard let styleURL = definition.referenceStyle.fetchStyleURL(variant: variant, apiKey: key) else {
            throw MTOfflinePackError.styleResolutionFailed
        }
        return styleURL
    }

    // Resolves a source's tile URL template and zoom limits. Inline `tiles` use the style's zoom limits;
    // otherwise the TileJSON is fetched and its zoom limits take precedence.
    private func resolveSource(_ source: MTStyleSource) async throws -> MTOfflineSourceMetadata {
        if let tiles = source.tiles, let first = tiles.first {
            return MTOfflineSourceMetadata(
                id: source.id,
                type: source.type.flatMap(MTSourceType.init(rawValue:)),
                tileURLTemplate: first,
                minZoom: source.minZoom ?? 0,
                maxZoom: source.maxZoom ?? 22
            )
        }

        guard let urlString = source.url, let url = URL(string: urlString) else {
            throw MTOfflinePackError.networkError(URLError(.badURL))
        }

        let data = try await fetch(url)
        guard let tileJSON = try? JSONDecoder().decode(MTTileJSON.self, from: data),
            let template = tileJSON.preferredTileURLTemplate else {
            throw MTOfflinePackError.networkError(URLError(.cannotParseResponse))
        }

        return MTOfflineSourceMetadata(
            id: source.id,
            type: source.type.flatMap(MTSourceType.init(rawValue:)),
            tileURLTemplate: template,
            minZoom: tileJSON.minzoom,
            maxZoom: tileJSON.maxzoom
        )
    }

    private func fetch(_ url: URL) async throws -> Data {
        let normalizedURL = await MTURLNormalizer.normalize(url: url)
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: normalizedURL)
        } catch {
            throw MTOfflinePackError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode else {
            throw MTOfflinePackError.networkError(URLError(.badServerResponse))
        }
        return data
    }
}
