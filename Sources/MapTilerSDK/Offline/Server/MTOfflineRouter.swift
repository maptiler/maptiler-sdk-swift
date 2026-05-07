//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineRouter.swift
//  MapTilerSDK
//

import Foundation

// Handles routing of offline asset requests to local file system paths.
internal struct MTOfflineRouter {
    private let rootDirectory: URL

    init(rootDirectory: URL = MTOfflineStoragePaths.rootDirectory) {
        self.rootDirectory = rootDirectory
    }

    // Resolves a virtual path to a local file URL and its MIME type.
    func resolve(path: String) -> (url: URL, mimeType: String)? {
        // We expect paths starting with /offline/
        guard path.hasPrefix("/offline/") else {
            return nil
        }

        // Strip the /offline/ prefix
        let relativePath = String(path.dropFirst("/offline/".count))
        let components = relativePath.components(separatedBy: "/")

        // Minimum expected: <packID>/<resource>
        guard components.count >= 2 else {
            return nil
        }

        let packID = components[0]
        let resourcePath = components.dropFirst().joined(separator: "/")

        let packDir = rootDirectory.appendingPathComponent(packID, isDirectory: true)

        // Handle specific resource types based on their paths
        if resourcePath == "style.json" {
            let fileURL = packDir.appendingPathComponent("style.json")
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
            return (fileURL, "application/json")
        }

        if resourcePath.hasPrefix("sprite") {
            let fileURL = packDir.appendingPathComponent(resourcePath)
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
            let mimeType = resourcePath.hasSuffix(".json") ? "application/json" : "image/png"
            return (fileURL, mimeType)
        }

        if resourcePath.hasPrefix("glyphs/") {
            return resolveGlyphs(packDir: packDir, glyphPath: String(resourcePath.dropFirst("glyphs/".count)))
        }

        if resourcePath.hasPrefix("tiles/") {
            return resolveTiles(packDir: packDir, tilePath: String(resourcePath.dropFirst("tiles/".count)))
        }

        return nil
    }

    private func resolveGlyphs(packDir: URL, glyphPath: String) -> (url: URL, mimeType: String)? {
        // glyphPath format: {fontstack}/{range}.pbf
        let components = glyphPath.components(separatedBy: "/")
        guard components.count == 2 else { return nil }

        let fontstack = components[0]
        let rangePbf = components[1]

        // Handle fontstack lists by picking the first available font directory.
        let fonts = fontstack.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let glyphsDir = packDir.appendingPathComponent("glyphs", isDirectory: true)

        for font in fonts {
            let fontDir = glyphsDir.appendingPathComponent(font, isDirectory: true)
            let fileURL = fontDir.appendingPathComponent(rangePbf)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return (fileURL, "application/x-protobuf")
            }
        }

        return nil
    }

    private func resolveTiles(packDir: URL, tilePath: String) -> (url: URL, mimeType: String)? {
        // tilePath format: {sourceId}/{z}/{x}/{y}.{ext}
        let components = tilePath.components(separatedBy: "/")
        guard components.count == 4 else { return nil }

        let sourceId = components[0]
        let z = components[1]
        let x = components[2]
        let yWithExt = components[3]

        let tilesDir = packDir.appendingPathComponent("tiles", isDirectory: true)
            .appendingPathComponent(sourceId, isDirectory: true)
            .appendingPathComponent(z, isDirectory: true)
            .appendingPathComponent(x, isDirectory: true)

        let fileURL = tilesDir.appendingPathComponent(yWithExt)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        let ext = (yWithExt as NSString).pathExtension.lowercased()
        let mimeType = mimeType(for: ext)

        return (fileURL, mimeType)
    }

    private func mimeType(for extensionName: String) -> String {
        switch extensionName {
        case "json": return "application/json"
        case "png": return "image/png"
        case "pbf": return "application/x-protobuf"
        case "webp": return "image/webp"
        case "jpg", "jpeg": return "image/jpeg"
        default: return "application/octet-stream"
        }
    }
}
