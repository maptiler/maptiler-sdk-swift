//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineEstimator.swift
//  MapTilerSDK
//

import Foundation

/// Provides estimation for offline pack size and resource counts.
///
/// Resource counts are exact: they are computed with the same planning logic the download uses.
/// The estimator never downloads tiles.
public struct MTOfflineEstimator: Sendable {

    // Average sizes in bytes for estimation purposes
    private static let averageTileSizeVector: Int64 = 25_000 // 25 KB
    private static let averageTileSizeRaster: Int64 = 150_000 // 150 KB
    private static let averageSpriteSize: Int64 = 50_000 // 50 KB
    private static let averageGlyphRangeSize: Int64 = 15_000 // 15 KB
    private static let averageStyleSize: Int64 = 100_000 // 100 KB

    private let resolver: MTOfflineMetadataResolver

    public init() {
        self.init(resolver: .shared)
    }

    internal init(resolver: MTOfflineMetadataResolver) {
        self.resolver = resolver
    }

    /// Estimates the size and resource count for a given region definition.
    ///
    /// This fetches the style JSON and the TileJSON of each style source (cached for a short time and reused
    /// by a subsequent download). No tiles are requested.
    ///
    /// - Parameter region: The definition of the region to estimate.
    /// - Returns: An `MTPackStats` object containing the estimates.
    /// - Throws: An error if the region is invalid or the style metadata cannot be fetched.
    public func estimatePack(region: MTOfflineRegionDefinition) async throws -> MTPackStats {
        try region.validateForOffline()
        let metadata = try await resolver.metadata(for: region)
        return try estimatePack(region: region, styleMetadata: metadata)
    }

    /// Estimates the size and resource count for a given region definition without any network requests.
    ///
    /// - Parameters:
    ///   - region: The definition of the region to estimate.
    ///   - styleMetadata: Previously resolved metadata of the region's style, see `styleMetadata(for:)`.
    /// - Returns: An `MTPackStats` object containing the estimates.
    /// - Throws: An error if the region is invalid or terrain is enabled but the metadata has no terrain source.
    public func estimatePack(
        region: MTOfflineRegionDefinition,
        styleMetadata: MTOfflineStyleMetadata
    ) throws -> MTPackStats {
        let plan = try MTOfflineResourcePlan(definition: region, metadata: styleMetadata)

        var expectedSize = Int64(plan.styleCount) * MTOfflineEstimator.averageStyleSize
        expectedSize += Int64(plan.spriteCount) * MTOfflineEstimator.averageSpriteSize
        expectedSize += Int64(plan.glyphCount) * MTOfflineEstimator.averageGlyphRangeSize

        let sources = plan.sources.map { sourcePlan in
            let isRaster = sourcePlan.source.type?.contains("raster") == true
            let averageTileSize = isRaster
                ? MTOfflineEstimator.averageTileSizeRaster
                : MTOfflineEstimator.averageTileSizeVector
            expectedSize += Int64(sourcePlan.tileCount) * averageTileSize

            return MTSourceStats(
                id: sourcePlan.source.id,
                type: sourcePlan.source.type,
                minZoom: sourcePlan.zoomRange.lowerBound,
                maxZoom: sourcePlan.zoomRange.upperBound,
                tilesPerZoom: Dictionary(uniqueKeysWithValues: sourcePlan.coverages.map { ($0.zoom, $0.tileCount) })
            )
        }

        return MTPackStats(
            expectedSize: expectedSize,
            resourceCount: plan.resourceCount,
            sources: sources,
            glyphCount: plan.glyphCount,
            spriteCount: plan.spriteCount,
            styleCount: plan.styleCount,
            resourceLimit: plan.resourceLimit
        )
    }

    /// Counts the tiles of a region per source, zoom level and ancestor tile, without any network requests.
    ///
    /// Tiles at zoom levels up to `groupZoom` are reported individually (each tile is its own group with a count
    /// of 1). Tiles at deeper zoom levels are grouped by their ancestor at `groupZoom`. This lets a size model
    /// that knows how large each area is at `groupZoom` estimate the bytes of deeper zoom levels.
    ///
    /// - Parameters:
    ///   - region: The definition of the region.
    ///   - styleMetadata: Previously resolved metadata of the region's style.
    ///   - groupZoom: The zoom level of the ancestor tiles used for grouping.
    /// - Returns: The tile groups of every source.
    public func tileGroups(
        region: MTOfflineRegionDefinition,
        styleMetadata: MTOfflineStyleMetadata,
        groupZoom: Int
    ) throws -> [MTTileGroup] {
        let plan = try MTOfflineResourcePlan(definition: region, metadata: styleMetadata)
        var groups: [MTTileGroup] = []

        for sourcePlan in plan.sources {
            for coverage in sourcePlan.coverages {
                let ancestorZoom = Swift.min(coverage.zoom, Swift.max(0, groupZoom))
                for (ancestor, count) in coverage.tileCountsByAncestor(atZoom: ancestorZoom) {
                    groups.append(MTTileGroup(
                        sourceId: sourcePlan.source.id,
                        zoom: coverage.zoom,
                        ancestorZoom: ancestorZoom,
                        ancestorX: ancestor.x,
                        ancestorY: ancestor.y,
                        tileCount: count
                    ))
                }
            }
        }
        return groups
    }

    /// Resolves the metadata of a region's style by fetching the style JSON and its sources' TileJSON.
    ///
    /// Store the result to estimate later with `estimatePack(region:styleMetadata:)` without network requests.
    /// The metadata depends on the region's style, variant and terrain setting, not on its geometry or zoom levels.
    /// API keys and session ids are removed from its URLs, so it can be stored without exposing your key.
    ///
    /// - Parameter region: A region using the style to resolve.
    /// - Returns: The resolved style metadata.
    public func styleMetadata(for region: MTOfflineRegionDefinition) async throws -> MTOfflineStyleMetadata {
        try await resolver.metadata(for: region).redacted()
    }
}

/// Tiles of one source at one zoom level that share an ancestor tile.
public struct MTTileGroup: Equatable, Sendable {
    /// The source identifier from the style.
    public let sourceId: String
    /// The zoom level of the tiles.
    public let zoom: Int
    /// The zoom level of the shared ancestor tile. Equal to `zoom` when tiles are reported individually.
    public let ancestorZoom: Int
    /// The X coordinate of the ancestor tile (XYZ scheme).
    public let ancestorX: Int
    /// The Y coordinate of the ancestor tile (XYZ scheme).
    public let ancestorY: Int
    /// The number of tiles downloaded under the ancestor tile at `zoom`.
    public let tileCount: Int
}
