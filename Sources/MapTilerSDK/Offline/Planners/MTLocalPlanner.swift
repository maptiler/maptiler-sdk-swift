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
        throw MTOfflinePackError.notImplemented
    }

    internal func generateManifest(for definition: MTOfflineRegionDefinition) async throws -> MTManifest {
        try validate(definition: definition)

        let metadata = MTManifestMetadata(
            mapId: definition.mapId,
            styleURL: definition.styleURL,
            bbox: definition.bbox,
            minZoom: definition.minZoom,
            maxZoom: definition.maxZoom,
            pixelRatio: definition.pixelRatio
        )

        let styleResource: MTMapResource?
        if let styleURL = definition.styleURL {
            styleResource = try await resolveStyle(url: styleURL)
        } else if let mapId = definition.mapId {
            styleResource = try await resolveStyle(mapId: mapId)
        } else {
            styleResource = nil
        }

        let tileResources = try await generateTileResources(
            bbox: definition.bbox,
            minZoom: definition.minZoom,
            maxZoom: definition.maxZoom
        )

        let glyphResources = try await generateGlyphResources(style: styleResource)
        let spriteResources = try await generateSpriteResources(style: styleResource)

        return MTManifest(
            metadata: metadata,
            style: styleResource,
            tiles: tileResources,
            glyphs: glyphResources,
            sprites: spriteResources
        )
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

    private func resolveStyle(url: URL) async throws -> MTMapResource? {
        // Implement style JSON network fetch, parsing, and MTMapResource mapping.
        return nil
    }

    private func resolveStyle(mapId: String) async throws -> MTMapResource? {
        // Implement resolving mapId to a full style URL and fetching it.
        return nil
    }

    private func generateTileResources(
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int
    ) async throws -> [MTMapResource] {
        // Implement tile math algorithm to determine which exact X/Y/Z tiles are needed.
        return []
    }

    private func generateGlyphResources(style: MTMapResource?) async throws -> [MTMapResource] {
        // Parse the resolved style.json for `glyphs` URL templates and create resource items.
        return []
    }

    private func generateSpriteResources(style: MTMapResource?) async throws -> [MTMapResource] {
        // Parse the resolved style.json for `sprite` URL templates and create resource items.
        return []
    }
}
