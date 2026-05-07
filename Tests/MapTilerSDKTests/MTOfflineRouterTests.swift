//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineRouterTests.swift
//  MapTilerSDK
//

import Foundation
import Testing
@testable import MapTilerSDK

@Suite
struct MTOfflineRouterTests {
    
    func withTempDirectory(_ body: (URL) throws -> Void) throws {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer {
            try? fileManager.removeItem(at: tempDir)
        }
        try body(tempDir)
    }

    @Test func testStyleRouting() throws {
        try withTempDirectory { rootDir in
            let packID = "test-pack"
            let packDir = rootDir.appendingPathComponent(packID)
            try FileManager.default.createDirectory(at: packDir, withIntermediateDirectories: true)
            
            let styleURL = packDir.appendingPathComponent("style.json")
            try "{}".data(using: .utf8)?.write(to: styleURL)
            
            let router = MTOfflineRouter(rootDirectory: rootDir)
            let result = router.resolve(path: "/offline/\(packID)/style.json")
            
            #expect(result != nil)
            #expect(result?.url.path == styleURL.path)
            #expect(result?.mimeType == "application/json")
        }
    }

    @Test func testSpriteRouting() throws {
        try withTempDirectory { rootDir in
            let packID = "test-pack"
            let packDir = rootDir.appendingPathComponent(packID)
            try FileManager.default.createDirectory(at: packDir, withIntermediateDirectories: true)
            
            let spriteJSON = packDir.appendingPathComponent("sprite.json")
            try "{}".data(using: .utf8)?.write(to: spriteJSON)
            
            let spritePNG = packDir.appendingPathComponent("sprite@2x.png")
            try Data().write(to: spritePNG)
            
            let router = MTOfflineRouter(rootDirectory: rootDir)
            
            let jsonResult = router.resolve(path: "/offline/\(packID)/sprite.json")
            #expect(jsonResult?.url.path == spriteJSON.path)
            #expect(jsonResult?.mimeType == "application/json")
            
            let pngResult = router.resolve(path: "/offline/\(packID)/sprite@2x.png")
            #expect(pngResult?.url.path == spritePNG.path)
            #expect(pngResult?.mimeType == "image/png")
        }
    }

    @Test func testGlyphsRoutingWithFontstackFallback() throws {
        try withTempDirectory { rootDir in
            let packID = "test-pack"
            let font1 = "Roboto Regular"
            let font2 = "Noto Sans Regular"
            let glyphsDir = rootDir.appendingPathComponent(packID).appendingPathComponent("glyphs")
            let font2Dir = glyphsDir.appendingPathComponent(font2)
            try FileManager.default.createDirectory(at: font2Dir, withIntermediateDirectories: true)
            
            let glyphURL = font2Dir.appendingPathComponent("0-255.pbf")
            try Data().write(to: glyphURL)
            
            let router = MTOfflineRouter(rootDirectory: rootDir)
            
            // Should skip font1 (not present) and find font2
            let path = "/offline/\(packID)/glyphs/\(font1),\(font2)/0-255.pbf"
            let result = router.resolve(path: path)
            
            #expect(result != nil)
            #expect(result?.url.path == glyphURL.path)
            #expect(result?.mimeType == "application/x-protobuf")
        }
    }

    @Test func testTileRouting() throws {
        try withTempDirectory { rootDir in
            let packID = "test-pack"
            let sourceId = "maptiler-streets"
            let tilePath = "tiles/\(sourceId)/1/2/3.pbf"
            let tilesDir = rootDir.appendingPathComponent(packID).appendingPathComponent("tiles/\(sourceId)/1/2")
            try FileManager.default.createDirectory(at: tilesDir, withIntermediateDirectories: true)
            
            let fullTileURL = tilesDir.appendingPathComponent("3.pbf")
            try Data().write(to: fullTileURL)
            
            let router = MTOfflineRouter(rootDirectory: rootDir)
            let result = router.resolve(path: "/offline/\(packID)/\(tilePath)")
            
            #expect(result != nil)
            #expect(result?.url.path == fullTileURL.path)
            #expect(result?.mimeType == "application/x-protobuf")
        }
    }

    @Test func testInvalidPaths() throws {
        let router = MTOfflineRouter()
        
        #expect(router.resolve(path: "/health") == nil)
        #expect(router.resolve(path: "/offline/only-pack-id") == nil)
        #expect(router.resolve(path: "/other/prefix/pack/style.json") == nil)
    }

    @Test func testMissingFilesReturnNil() throws {
        try withTempDirectory { rootDir in
            let router = MTOfflineRouter(rootDirectory: rootDir)
            #expect(router.resolve(path: "/offline/nonexistent/style.json") == nil)
        }
    }
}
