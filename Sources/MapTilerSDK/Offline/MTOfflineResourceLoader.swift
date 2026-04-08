//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineResourceLoader.swift
//  MapTilerSDK
//

import Foundation

// A shared utility structure to manage and load offline map resources.
internal class MTOfflineResourceLoader {

    // The base directory URL where offline packs are stored.
    private let baseDirectoryURL: URL

    init(baseDirectoryURL: URL) {
        self.baseDirectoryURL = baseDirectoryURL
    }

    func loadStyle(packName: String, styleName: String) -> Data? {
        let fileURL = baseDirectoryURL
            .appendingPathComponent(packName)
            .appendingPathComponent("styles")
            .appendingPathComponent(styleName)
            .appendingPathComponent("style.json")

        return try? Data(contentsOf: fileURL)
    }

    func loadTileJSON(packName: String, sourceName: String) -> Data? {
        let fileURL = baseDirectoryURL
            .appendingPathComponent(packName)
            .appendingPathComponent("sources")
            .appendingPathComponent(sourceName)
            .appendingPathComponent("tiles.json")

        return try? Data(contentsOf: fileURL)
    }

    func loadTile(packName: String, sourceName: String, z: Int, x: Int, y: Int) -> Data? {
        let sourceDir = baseDirectoryURL
            .appendingPathComponent(packName)
            .appendingPathComponent("tiles")
            .appendingPathComponent(sourceName)
            .appendingPathComponent("\(z)")
            .appendingPathComponent("\(x)")

        // Common extensions used for map tiles
        let possibleExtensions = ["pbf", "png", "jpg", "jpeg", "webp"]

        for ext in possibleExtensions {
            let fileURL = sourceDir.appendingPathComponent("\(y).\(ext)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return try? Data(contentsOf: fileURL)
            }
        }

        return nil
    }

    func loadSpriteJSON(packName: String, spriteName: String) -> Data? {
        let fileURL = baseDirectoryURL
            .appendingPathComponent(packName)
            .appendingPathComponent("sprites")
            .appendingPathComponent(spriteName)
            .appendingPathComponent("sprite.json")

        return try? Data(contentsOf: fileURL)
    }

    func loadSpritePNG(packName: String, spriteName: String) -> Data? {
        let fileURL = baseDirectoryURL
            .appendingPathComponent(packName)
            .appendingPathComponent("sprites")
            .appendingPathComponent(spriteName)
            .appendingPathComponent("sprite.png")

        return try? Data(contentsOf: fileURL)
    }

    func loadGlyphs(packName: String, fontStack: String, range: String) -> Data? {
        let fileURL = baseDirectoryURL
            .appendingPathComponent(packName)
            .appendingPathComponent("glyphs")
            .appendingPathComponent(fontStack)
            .appendingPathComponent("\(range).pbf")

        return try? Data(contentsOf: fileURL)
    }

    func loadMetadata(packName: String) -> Data? {
        let fileURL = baseDirectoryURL
            .appendingPathComponent(packName)
            .appendingPathComponent("metadata.json")

        return try? Data(contentsOf: fileURL)
    }

    func calculateSize(packName: String) -> Int64 {
        let packURL = baseDirectoryURL.appendingPathComponent(packName)
        var totalSize: Int64 = 0

        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(at: packURL, includingPropertiesForKeys: [.fileSizeKey])

        while let fileURL = enumerator?.nextObject() as? URL {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                let fileSize = resourceValues.fileSize {
                    totalSize += Int64(fileSize)
            }
        }

        return totalSize
    }
}
