//
//  MTSyntheticManifest.swift
//  MapTilerSDK
//

import Foundation

// The type of tile source.
internal enum MTSyntheticTileSourceType: String, Codable, Equatable {
    case vector
    case raster
    case rasterDem = "raster-dem"
}

// A set of sprites for a specific scale.
internal struct MTSpriteSet: Codable, Equatable {
    internal var baseName: String
    internal var scale: Int
    internal var files: [String]
}

// A set of glyph ranges for a specific font stack.
internal struct MTGlyphSet: Codable, Equatable {
    internal var fontStack: String
    internal var ranges: [String]
}

// A tile source with its type and associated tile keys or URLs.
internal struct MTSyntheticTileSource: Codable, Equatable {
    internal var type: MTSyntheticTileSourceType
    internal var tileKeys: [String]
}

// The Manifest v1 schema defining the bill of materials for an offline region.
internal struct MTManifestV1: Codable, Equatable {
    internal var version: String = "1"
    internal var style: String
    internal var sprites: [MTSpriteSet]
    internal var glyphs: [MTGlyphSet]
    internal var tiles: [String: MTSyntheticTileSource]

    internal init(
        style: String,
        sprites: [MTSpriteSet] = [],
        glyphs: [MTGlyphSet] = [],
        tiles: [String: MTSyntheticTileSource] = [:]
    ) {
        self.style = style
        self.sprites = sprites
        self.glyphs = glyphs
        self.tiles = tiles
    }
}

internal enum MTSyntheticManifestError: Error, Equatable {
    case unsupportedVersion(String)
}

// A builder and container for the manifest data.
internal class MTSyntheticManifest {
    internal var manifest: MTManifestV1

    internal init(manifest: MTManifestV1) {
        self.manifest = manifest
    }

    internal init(style: String) {
        self.manifest = MTManifestV1(style: style)
    }

    internal func addSpriteSet(_ spriteSet: MTSpriteSet) {
        manifest.sprites.append(spriteSet)
    }

    internal func addGlyphSet(_ glyphSet: MTGlyphSet) {
        manifest.glyphs.append(glyphSet)
    }

    internal func addTileSource(id: String, source: MTSyntheticTileSource) {
        manifest.tiles[id] = source
    }

    internal func toJSONData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(manifest)
    }

    internal static func fromJSONData(_ data: Data) throws -> MTSyntheticManifest {
        struct VersionPeek: Codable {
            let version: String
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let peek = try decoder.decode(VersionPeek.self, from: data)

        switch peek.version {
        case "1":
            let decoded = try decoder.decode(MTManifestV1.self, from: data)
            return MTSyntheticManifest(manifest: decoded)
        default:
            throw MTSyntheticManifestError.unsupportedVersion(peek.version)
        }
    }
}
