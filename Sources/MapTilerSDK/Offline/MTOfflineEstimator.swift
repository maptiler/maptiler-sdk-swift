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
public struct MTOfflineEstimator: Sendable {

    // Average sizes in bytes for estimation purposes
    private static let averageTileSizeVector: Int64 = 25_000 // 25 KB
    private static let averageTileSizeRaster: Int64 = 150_000 // 150 KB
    private static let averageSpriteSize: Int64 = 50_000 // 50 KB
    private static let averageGlyphRangeSize: Int64 = 15_000 // 15 KB
    private static let averageStyleSize: Int64 = 100_000 // 100 KB

    public init() {}

    /// Estimates the size and resource count for a given region definition.
    ///
    /// This method may fetch the style JSON and other metadata if needed to provide a more accurate estimate.
    ///
    /// - Parameter region: The definition of the region to estimate.
    /// - Returns: An `MTPackStats` object containing the estimates.
    /// - Throws: An error if style fetching or parsing fails.
    public func estimatePack(region: MTOfflineRegionDefinition) async throws -> MTPackStats {
        let zoomRange = try MTOfflineZoomRange(minZoom: region.minZoom, maxZoom: region.maxZoom)

        guard let key = await MTConfig.shared.getAPIKey(),
            let styleURL = region.referenceStyle.fetchStyleURL(variant: region.styleVariant, apiKey: key) else {
            // If no style URL, we can only estimate based on tile count if we assume a single vector source
            let tileCount = MTTileMath.estimateTileCount(for: region.geometry, zoomRange: zoomRange)
            return MTPackStats(
                expectedSize: Int64(tileCount) * MTOfflineEstimator.averageTileSizeVector,
                resourceCount: tileCount,
                tilesPerSource: ["default": tileCount]
            )
        }

        let (data, _) = try await URLSession.shared.data(from: styleURL)

        do {
            let parser = MTStyleParser()
            let dependencies = try parser.extractDependencies(from: data)

            var totalSize: Int64 = MTOfflineEstimator.averageStyleSize
            var totalResourceCount = 1 // Style itself

            let spriteCount = dependencies.sprites.count * 2 // JSON + PNG
            totalResourceCount += spriteCount
            totalSize += Int64(spriteCount) * MTOfflineEstimator.averageSpriteSize

            // Rough estimate: we download common glyph ranges for each font stack
            // Common ranges are 0-255 (Basic Latin) and maybe a few others.
            // Let's assume 4 ranges per font stack for estimation.
            let glyphRangesPerFontStack = 4
            let glyphCount = dependencies.fontStacks.count * glyphRangesPerFontStack
            totalResourceCount += glyphCount
            totalSize += Int64(glyphCount) * MTOfflineEstimator.averageGlyphRangeSize

            var tilesPerSource: [String: Int] = [:]

            for source in dependencies.sources {
                // Source-specific zoom range constraints
                let sourceMinZoom = max(region.minZoom, source.minZoom ?? 0)
                let sourceMaxZoom = min(region.maxZoom, source.maxZoom ?? 22)

                if sourceMinZoom <= sourceMaxZoom {
                    if let sourceZoomRange = try? MTOfflineZoomRange(minZoom: sourceMinZoom, maxZoom: sourceMaxZoom) {
                        let tileCount = MTTileMath.estimateTileCount(for: region.geometry, zoomRange: sourceZoomRange)
                        tilesPerSource[source.id] = tileCount
                        totalResourceCount += tileCount

                        if let type = source.type, type.contains("raster") {
                            totalSize += Int64(tileCount) * MTOfflineEstimator.averageTileSizeRaster
                        } else {
                            // Default to vector
                            totalSize += Int64(tileCount) * MTOfflineEstimator.averageTileSizeVector
                        }
                    }
                }
            }

            return MTPackStats(
                expectedSize: totalSize,
                resourceCount: totalResourceCount,
                tilesPerSource: tilesPerSource
            )
        } catch {
            // Fallback to basic estimation if parsing fails
            let tileCount = MTTileMath.estimateTileCount(for: region.geometry, zoomRange: zoomRange)
            return MTPackStats(
                expectedSize: Int64(tileCount) * MTOfflineEstimator.averageTileSizeVector,
                resourceCount: tileCount,
                tilesPerSource: ["default": tileCount]
            )
        }
    }
}
