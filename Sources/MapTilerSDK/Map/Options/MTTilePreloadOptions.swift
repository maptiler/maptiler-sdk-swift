//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTTilePreloadOptions.swift
//  MapTilerSDK
//

/// Experimental options controlling tile preloading.
///
/// Set as ``MTAnimationOptions/experimentalPreload`` on camera animations (fly, ease, pan, zoom, fit bounds)
/// to fetch the tiles along the camera path before the animation starts. The animation begins once
/// preloading completes.
///
/// Preloading only works when the map was created with ``MTMapOptions/useExperimentalTilePreloading``
/// set to `true`.
///  - Note: Every preloaded tile counts against your MapTiler Cloud API key quota.
public struct MTTilePreloadOptions: Sendable, Codable, Equatable {
    /// Maximum number of tiles to fetch across all sources. Tiles beyond this limit are skipped.
    ///
    /// Defaults to 512 when nil.
    public var maxTiles: Int?

    /// Initializes the options.
    /// - Parameters:
    ///   - maxTiles: Maximum number of tiles to fetch across all sources.
    public init(maxTiles: Int? = nil) {
        self.maxTiles = maxTiles
    }
}
