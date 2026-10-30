//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLocalPlanner.swift
//  MapTilerSDK
//

import Foundation

// Plans offline downloads locally from the style and TileJSON metadata.
internal class MTLocalPlanner: MTOfflinePlanner {

    // Resolves (and briefly caches) style metadata for planning.
    private let resolver: MTOfflineMetadataResolver

    // Initializes a new planner with dependency injection.
    internal init(session: URLSession = MTConfig.sharedURLSession) {
        self.resolver = session === MTConfig.sharedURLSession ? .shared : MTOfflineMetadataResolver(session: session)
    }

    internal func estimate(for definition: MTOfflineRegionDefinition) async throws -> MTTileEstimate {
        let estimator = MTOfflineEstimator(resolver: resolver)
        let stats = try await estimator.estimatePack(region: definition)

        if stats.exceedsLimit {
            throw MTOfflineError.exceedsMaximumTileCount(limit: stats.resourceLimit, requested: stats.resourceCount)
        }

        return MTTileEstimate(stats: stats)
    }

    internal func generateManifest(for definition: MTOfflineRegionDefinition) async throws -> MTManifest {
        try definition.validateForOffline()

        let metadata = try await resolver.metadata(for: definition)
        let plan = try MTOfflineResourcePlan(definition: definition, metadata: metadata)

        if plan.resourceCount > plan.resourceLimit {
            throw MTOfflineError.exceedsMaximumTileCount(limit: plan.resourceLimit, requested: plan.resourceCount)
        }

        // Ensure the pack actually contains data.
        // If 0 tiles were found, the area/zoom combination is likely invalid or too small.
        guard plan.tileCount > 0 else {
            throw MTOfflineError.invalidRegion
        }

        let isFlexible = {
            if case .boundingBox = definition.geometry { return false }
            return true
        }()

        // For non-rectangular geometries, slightly pad the bounding box stored in the manifest.
        // MapLibre uses this manifest bbox to aggressively clip rendering. Without padding,
        // tiles on the exact edges of a route or polygon won't be drawn.
        var manifestBbox = definition.bbox
        if let pad = definition.effectivePaddingMeters, pad > 0, isFlexible {
            manifestBbox = manifestBbox.expanded(byMeters: pad)
        }

        let manifestMetadata = MTManifestMetadata(
            referenceStyle: definition.referenceStyle,
            styleVariant: definition.styleVariant,
            bbox: manifestBbox,
            minZoom: definition.minZoom,
            maxZoom: definition.maxZoom,
            pixelRatio: definition.pixelRatio,
            isTerrainEnabled: definition.isTerrainEnabled
        )

        let styleResource = metadata.styleURL
            .flatMap(URL.init(string:))
            .map { MTMapResource(url: $0, destinationPath: "style.json") }

        return MTManifest(
            metadata: manifestMetadata,
            style: styleResource,
            tiles: plan.tileResources(),
            glyphs: plan.glyphResources(),
            sprites: plan.spriteResources()
        )
    }
}
