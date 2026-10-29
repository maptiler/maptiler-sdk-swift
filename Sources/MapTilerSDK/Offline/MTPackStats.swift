//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPackStats.swift
//  MapTilerSDK
//

import Foundation

/// Tile statistics for a single source of an offline pack.
public struct MTSourceStats: Equatable, Sendable {
    /// The source identifier from the style.
    public let id: String
    /// The source type (`vector`, `raster` or `raster-dem`).
    public let type: String?
    /// The lowest zoom level downloaded for this source.
    public let minZoom: Int
    /// The highest zoom level downloaded for this source. It may be lower than the requested maximum zoom
    /// when the source has no data beyond it; the map overzooms the downloaded tiles instead.
    public let maxZoom: Int
    /// The number of tiles downloaded per zoom level.
    public let tilesPerZoom: [Int: Int]

    /// The number of tiles downloaded for this source.
    public var tileCount: Int {
        tilesPerZoom.values.reduce(0, +)
    }

    public init(id: String, type: String?, minZoom: Int, maxZoom: Int, tilesPerZoom: [Int: Int]) {
        self.id = id
        self.type = type
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.tilesPerZoom = tilesPerZoom
    }
}

/// Statistics about an offline map pack.
public struct MTPackStats {
    /// Expected total size in bytes.
    ///
    /// This is a rough estimate based on average resource sizes. Real tile sizes vary widely between
    /// dense cities and empty areas, so the actual size can differ significantly.
    public let expectedSize: Int64
    /// Expected total number of resources (tiles, glyphs, sprites, style). Every resource is one request.
    public let resourceCount: Int
    /// Expected number of tiles per source.
    public let tilesPerSource: [String: Int]
    /// Per-source tile statistics, including the downloaded zoom range and tiles per zoom level.
    public let sources: [MTSourceStats]
    /// The number of glyph resources.
    public let glyphCount: Int
    /// The number of sprite resources.
    public let spriteCount: Int
    /// The number of style resources.
    public let styleCount: Int
    /// The maximum number of resources a single pack may contain for this region.
    public let resourceLimit: Int

    /// The total number of tiles.
    public var tileCount: Int {
        tilesPerSource.values.reduce(0, +)
    }

    /// Whether the region exceeds the resource limit and cannot be downloaded as a single pack.
    public var exceedsLimit: Bool {
        resourceCount > resourceLimit
    }

    /// The minimum number of packs needed to download the region.
    ///
    /// Every pack downloads the style, sprites and glyphs again, so only the remaining part of the limit is
    /// available for tiles. Splitting a region adds some tiles along the split edges, so the real number of
    /// packs can be higher. `nil` when the style resources alone exceed the limit.
    public var minimumPackCount: Int? {
        let tileBudget = resourceLimit - (glyphCount + spriteCount + styleCount)
        guard tileBudget > 0 else { return nil }
        return Swift.max(1, (tileCount + tileBudget - 1) / tileBudget)
    }

    public init(expectedSize: Int64, resourceCount: Int, tilesPerSource: [String: Int] = [:]) {
        self.init(
            expectedSize: expectedSize,
            resourceCount: resourceCount,
            sources: [],
            glyphCount: 0,
            spriteCount: 0,
            styleCount: 0,
            resourceLimit: MTOfflineConfiguration.shared.effectiveGlobalLimit,
            tilesPerSource: tilesPerSource
        )
    }

    public init(
        expectedSize: Int64,
        resourceCount: Int,
        sources: [MTSourceStats],
        glyphCount: Int,
        spriteCount: Int,
        styleCount: Int,
        resourceLimit: Int
    ) {
        self.init(
            expectedSize: expectedSize,
            resourceCount: resourceCount,
            sources: sources,
            glyphCount: glyphCount,
            spriteCount: spriteCount,
            styleCount: styleCount,
            resourceLimit: resourceLimit,
            tilesPerSource: Dictionary(sources.map { ($0.id, $0.tileCount) }, uniquingKeysWith: +)
        )
    }

    private init(
        expectedSize: Int64,
        resourceCount: Int,
        sources: [MTSourceStats],
        glyphCount: Int,
        spriteCount: Int,
        styleCount: Int,
        resourceLimit: Int,
        tilesPerSource: [String: Int]
    ) {
        self.expectedSize = expectedSize
        self.resourceCount = resourceCount
        self.tilesPerSource = tilesPerSource
        self.sources = sources
        self.glyphCount = glyphCount
        self.spriteCount = spriteCount
        self.styleCount = styleCount
        self.resourceLimit = resourceLimit
    }
}
