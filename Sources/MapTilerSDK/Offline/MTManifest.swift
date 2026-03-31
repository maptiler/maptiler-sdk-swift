//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTManifest.swift
//  MapTilerSDK
//

import Foundation

// Manifest v1 representing the planned offline region download.
internal struct MTManifest: Codable {
    /// The format version identifier.
    internal let version: String = "1"

    /// The original inputs used to generate this manifest.
    internal let metadata: MTManifestMetadata

    /// The style JSON resource.
    internal var style: MTMapResource?

    /// The list of tile resources to download.
    internal var tiles: [MTMapResource]

    /// The list of glyph resources.
    internal var glyphs: [MTMapResource]

    /// The list of sprite resources.
    internal var sprites: [MTMapResource]

    internal init(
        metadata: MTManifestMetadata,
        style: MTMapResource? = nil,
        tiles: [MTMapResource] = [],
        glyphs: [MTMapResource] = [],
        sprites: [MTMapResource] = []
    ) {
        self.metadata = metadata
        self.style = style
        self.tiles = tiles
        self.glyphs = glyphs
        self.sprites = sprites
    }
}
