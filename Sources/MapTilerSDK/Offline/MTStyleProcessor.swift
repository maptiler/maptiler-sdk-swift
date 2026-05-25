//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

// A utility responsible for transforming a map style dictionary to use local offline resources.
internal struct MTStyleProcessor {
    private let baseURL: String
    private let packName: String

    // Initializes a new style transformer.
    internal init(baseURL: String, packName: String) {
        self.baseURL = baseURL
        self.packName = packName
    }

    /// Transforms the given style dictionary into an offline-ready version.
    internal func transform(style: [String: Any]) -> [String: Any] {
        var transformed = style

        rewriteSprites(&transformed)
        rewriteGlyphs(&transformed)

        var purgedSourceIds = Set<String>()
        rewriteSources(&transformed, purgedSourceIds: &purgedSourceIds)
        rewriteLayers(&transformed, purgedSourceIds: purgedSourceIds)

        return transformed
    }

    private func rewriteSprites(_ transformed: inout [String: Any]) {
        guard let sprite = transformed["sprite"] else { return }

        if sprite is String {
            transformed["sprite"] = "\(baseURL)/offline/\(packName)/sprite"
        } else if let spriteArray = sprite as? [[String: Any]] {
            var updatedSprites = [[String: Any]]()
            for var spriteObj in spriteArray {
                let id = spriteObj["id"] as? String
                let suffix = (id == nil || id == "default") ? "" : "-\(id!)"
                spriteObj["url"] = "\(baseURL)/offline/\(packName)/sprite\(suffix)"
                updatedSprites.append(spriteObj)
            }
            transformed["sprite"] = updatedSprites
        }
    }

    private func rewriteGlyphs(_ transformed: inout [String: Any]) {
        if transformed["glyphs"] != nil {
            transformed["glyphs"] = "\(baseURL)/offline/\(packName)/glyphs/{fontstack}/{range}.pbf"
        }
    }

    private func rewriteSources(_ transformed: inout [String: Any], purgedSourceIds: inout Set<String>) {
        guard var sources = transformed["sources"] as? [String: [String: Any]] else { return }

        let sourcesToPurge = ["maptiler_attribution"]
        for id in sourcesToPurge where sources.removeValue(forKey: id) != nil {
            purgedSourceIds.insert(id)
        }

        for (sourceId, source) in sources {
            sources[sourceId] = transformSource(sourceId: sourceId, source: source)
        }
        transformed["sources"] = sources
    }

    private func rewriteLayers(_ transformed: inout [String: Any], purgedSourceIds: Set<String>) {
        guard var layers = transformed["layers"] as? [[String: Any]] else { return }

        layers.removeAll { layer in
            if let sourceId = layer["source"] as? String {
                return purgedSourceIds.contains(sourceId)
            }
            return false
        }
        transformed["layers"] = layers
    }

    private func transformSource(sourceId: String, source: [String: Any]) -> [String: Any] {
        var updatedSource = source

        // Only process vector and raster sources
        guard let type = updatedSource["type"] as? String,
            type == "vector" || type == "raster" || type == "raster-dem" else {
            return updatedSource
        }

        // Remove remote URL property as we are providing explicit tiles array
        updatedSource.removeValue(forKey: "url")

        // Remove scheme to ensure local XYZ storage is used correctly by the renderer
        updatedSource.removeValue(forKey: "scheme")

        // Determine extension for the local tiles
        let ext = determineExtension(source: source)

        // Inject local tiles array with the 127.0.0.1 template
        updatedSource["tiles"] = [
            "\(baseURL)/offline/\(packName)/tiles/\(sourceId)/{z}/{x}/{y}.\(ext)"
        ]

        return updatedSource
    }

    private func determineExtension(source: [String: Any]) -> String {
        guard let type = source["type"] as? String else { return "pbf" }

        if type == "vector" {
            return "pbf"
        }

        // For raster, try to find it in existing tiles array if present
        if let tiles = source["tiles"] as? [String], let firstTile = tiles.first {
            let lower = firstTile.lowercased()
            if lower.contains(".png") { return "png" }
            if lower.contains(".jpg") || lower.contains(".jpeg") { return "jpg" }
            if lower.contains(".webp") { return "webp" }
        }

        // Check source URL for hints about satellite or specific layers
        if let url = source["url"] as? String {
            let lower = url.lowercased()
            if lower.contains("satellite") {
                return "jpg" // MapTiler Satellite default format is JPG
            }
        }

        // Default for raster/raster-dem
        return "png"
    }
}
