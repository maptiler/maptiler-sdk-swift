//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

// Represents a TileJSON metadata object.
internal struct MTTileJSON: Codable, Sendable {
    // An array of tile endpoints.
    internal let tiles: [String]

    // The coordinate scheme used. Default is "xyz".
    internal let scheme: MTTileScheme

    // The bounds of the map [west, south, east, north].
    internal let bounds: [Double]?

    // An integer specifying the minimum zoom level. Default is 0.
    internal let minzoom: Int

    // An integer specifying the maximum zoom level. Default is 30.
    internal let maxzoom: Int

    /// The size of the tiles in pixels. Default is 256.
    public let tileSize: Int

    internal enum CodingKeys: String, CodingKey {
        case tiles
        case scheme
        case bounds
        case minzoom
        case maxzoom
        case tileSize
        case tile_size
        case tilesize
    }

    // Creates a new TileJSON instance.
    internal init(
        tiles: [String],
        scheme: MTTileScheme = .xyz,
        bounds: [Double]? = nil,
        minzoom: Int = 0,
        maxzoom: Int = 30,
        tileSize: Int = 256
    ) {
        self.tiles = tiles
        self.scheme = scheme
        self.bounds = bounds
        self.minzoom = minzoom
        self.maxzoom = maxzoom
        self.tileSize = tileSize
    }

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.tiles = try container.decode([String].self, forKey: .tiles)

        if let schemeStr = try container.decodeIfPresent(String.self, forKey: .scheme),
            let schemeVal = MTTileScheme(rawValue: schemeStr.lowercased()) {
            self.scheme = schemeVal
        } else {
            self.scheme = .xyz
        }

        self.bounds = try container.decodeIfPresent([Double].self, forKey: .bounds)
        self.minzoom = try container.decodeIfPresent(Int.self, forKey: .minzoom) ?? 0
        self.maxzoom = try container.decodeIfPresent(Int.self, forKey: .maxzoom) ?? 30

        if let size = try container.decodeIfPresent(Int.self, forKey: .tileSize) {
            self.tileSize = size
        } else if let size = try container.decodeIfPresent(Int.self, forKey: .tile_size) {
            self.tileSize = size
        } else if let size = try container.decodeIfPresent(Int.self, forKey: .tilesize) {
            self.tileSize = size
        } else {
            self.tileSize = 256
        }
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tiles, forKey: .tiles)
        try container.encode(scheme, forKey: .scheme)
        try container.encodeIfPresent(bounds, forKey: .bounds)
        try container.encode(minzoom, forKey: .minzoom)
        try container.encode(maxzoom, forKey: .maxzoom)
        try container.encode(tileSize, forKey: .tileSize)
    }
}

extension MTTileJSON {
    // Safely converts the raw array bounds into an `MTBoundingBox`.
    // TileJSON bounds are ordered as [minLon, minLat, maxLon, maxLat].
    internal var boundingBox: MTBoundingBox? {
        guard let b = bounds, b.count == 4 else { return nil }
        return MTBoundingBox(minLon: b[0], minLat: b[1], maxLon: b[2], maxLat: b[3])
    }

    // Generates a valid URL for a given tile coordinate using the first available template.
    internal func resolveURL(z: Int, x: Int, y: Int) -> URL? {
        guard let template = tiles.first else { return nil }

        var yCoord = y
        // If the scheme is TMS, the Y axis needs to be flipped.
        if scheme == .tms {
            yCoord = (1 << z) - 1 - y
        }

        let urlString = template
            .replacingOccurrences(of: "{z}", with: String(z))
            .replacingOccurrences(of: "{x}", with: String(x))
            .replacingOccurrences(of: "{y}", with: String(yCoord))

        return URL(string: urlString)
    }
}
