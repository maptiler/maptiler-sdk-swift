//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineStyleMetadata.swift
//  MapTilerSDK
//

import Foundation

/// A tile source of a style, resolved to the zoom range and URL template the offline planner uses.
public struct MTOfflineSourceMetadata: Codable, Equatable, Sendable {
    /// The source identifier from the style.
    public let id: String
    /// The source type (`vector`, `raster` or `raster-dem`).
    public let type: String?
    /// The tile URL template used for downloads.
    public let tileURLTemplate: String
    /// The minimum zoom level provided by the source.
    public let minZoom: Int
    /// The maximum zoom level provided by the source.
    public let maxZoom: Int

    public init(id: String, type: String?, tileURLTemplate: String, minZoom: Int, maxZoom: Int) {
        self.id = id
        self.type = type
        self.tileURLTemplate = tileURLTemplate
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }
}

/// A sprite referenced by a style.
public struct MTOfflineSpriteMetadata: Codable, Equatable, Sendable {
    /// The sprite identifier (`default` for a single sprite URL).
    public let id: String
    /// The sprite base URL, without extension.
    public let url: String

    public init(id: String, url: String) {
        self.id = id
        self.url = url
    }
}

/// Everything about a style that determines which resources an offline pack downloads.
///
/// Resolving it requires fetching the style JSON and the TileJSON of each source. Once resolved, it can be stored
/// and passed to `MTOfflineEstimator.estimatePack(region:styleMetadata:)` to estimate packs without any network
/// requests.
public struct MTOfflineStyleMetadata: Codable, Equatable, Sendable {
    /// The style JSON URL.
    public let styleURL: String?
    /// The tile sources of the style.
    public let sources: [MTOfflineSourceMetadata]
    /// The terrain source added when terrain is enabled and the style has no `raster-dem` source.
    public let terrainSource: MTOfflineSourceMetadata?
    /// The glyphs URL template.
    public let glyphsTemplate: String?
    /// The font stacks used by the style's symbol layers.
    public let fontStacks: [[String]]
    /// The sprites of the style.
    public let sprites: [MTOfflineSpriteMetadata]

    public init(
        styleURL: String?,
        sources: [MTOfflineSourceMetadata],
        terrainSource: MTOfflineSourceMetadata? = nil,
        glyphsTemplate: String?,
        fontStacks: [[String]],
        sprites: [MTOfflineSpriteMetadata]
    ) {
        self.styleURL = styleURL
        self.sources = sources
        self.terrainSource = terrainSource
        self.glyphsTemplate = glyphsTemplate
        self.fontStacks = fontStacks
        self.sprites = sprites
    }

    /// A copy without API keys and session ids in its URLs, so it can be stored or shared safely.
    ///
    /// Estimates only use the URL paths, so they are the same for the redacted copy.
    func redacted() -> MTOfflineStyleMetadata {
        func clean(_ url: String) -> String {
            let parts = url.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else {
                return url
            }

            let query = parts[1].split(separator: "&").filter { !$0.hasPrefix("key=") && !$0.hasPrefix("mtsid=") }
            return query.isEmpty ? String(parts[0]) : "\(parts[0])?\(query.joined(separator: "&"))"
        }

        func clean(_ source: MTOfflineSourceMetadata) -> MTOfflineSourceMetadata {
            MTOfflineSourceMetadata(
                id: source.id,
                type: source.type,
                tileURLTemplate: clean(source.tileURLTemplate),
                minZoom: source.minZoom,
                maxZoom: source.maxZoom
            )
        }

        return MTOfflineStyleMetadata(
            styleURL: styleURL.map(clean),
            sources: sources.map(clean),
            terrainSource: terrainSource.map(clean),
            glyphsTemplate: glyphsTemplate.map(clean),
            fontStacks: fontStacks,
            sprites: sprites.map { MTOfflineSpriteMetadata(id: $0.id, url: clean($0.url)) }
        )
    }
}
