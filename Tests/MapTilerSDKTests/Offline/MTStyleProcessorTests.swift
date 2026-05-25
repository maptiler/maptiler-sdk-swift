//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("MTStyleProcessor Tests", .serialized)
struct MTStyleProcessorTests {
    
    let baseURL = "http://127.0.0.1:18080"
    let packName = "test-pack"
    
    @Test("Transform style with vector source and sprite string")
    func testTransformVectorStyle() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let style: [String: Any] = [
            "version": 8,
            "sprite": "https://api.maptiler.com/sprite",
            "glyphs": "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf",
            "sources": [
                "maptiler": [
                    "type": "vector",
                    "url": "https://api.maptiler.com/tiles.json",
                    "scheme": "xyz"
                ]
            ]
        ]
        
        let transformed = transformer.transform(style: style)
        
        // Verify sprite
        #expect(transformed["sprite"] as? String == "\(baseURL)/offline/\(packName)/sprite")
        
        // Verify glyphs
        #expect(transformed["glyphs"] as? String == "\(baseURL)/offline/\(packName)/glyphs/{fontstack}/{range}.pbf")
        
        // Verify sources
        let sources = transformed["sources"] as? [String: [String: Any]]
        #expect(sources != nil)
        let source = sources?["maptiler"]
        #expect(source != nil)
        #expect(source?["type"] as? String == "vector")
        #expect(source?["url"] == nil)
        #expect(source?["scheme"] == nil)
        #expect(source?["tiles"] as? [String] == ["\(baseURL)/offline/\(packName)/tiles/maptiler/{z}/{x}/{y}.pbf"])
    }
    
    @Test("Transform style with raster source and sprite array")
    func testTransformRasterStyle() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let style: [String: Any] = [
            "version": 8,
            "sprite": [
                ["id": "default", "url": "https://api.maptiler.com/sprite1"],
                ["id": "dark", "url": "https://api.maptiler.com/sprite2"]
            ],
            "sources": [
                "satellite": [
                    "type": "raster",
                    "url": "https://api.maptiler.com/satellite.json",
                    "tileSize": 512
                ]
            ]
        ]
        
        let transformed = transformer.transform(style: style)
        
        // Verify sprites
        let sprites = transformed["sprite"] as? [[String: Any]]
        #expect(sprites?.count == 2)
        #expect(sprites?[0]["url"] as? String == "\(baseURL)/offline/\(packName)/sprite")
        #expect(sprites?[1]["url"] as? String == "\(baseURL)/offline/\(packName)/sprite-dark")
        
        // Verify sources
        let sources = transformed["sources"] as? [String: [String: Any]]
        let source = sources?["satellite"]
        #expect(source?["type"] as? String == "raster")
        #expect(source?["url"] == nil)
        #expect(source?["tiles"] as? [String] == ["\(baseURL)/offline/\(packName)/tiles/satellite/{z}/{x}/{y}.jpg"])
        #expect(source?["tileSize"] as? Int == 512)
    }

    @Test("Determine extension from existing tiles array")
    func testDetermineExtension() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let style: [String: Any] = [
            "sources": [
                "jpg-source": [
                    "type": "raster",
                    "tiles": ["https://example.com/{z}/{x}/{y}.jpg"]
                ],
                "webp-source": [
                    "type": "raster",
                    "tiles": ["https://example.com/{z}/{x}/{y}.webp"]
                ],
                "dem-source": [
                    "type": "raster-dem",
                    "url": "https://api.maptiler.com/dem.json"
                ]
            ]
        ]
        
        let transformed = transformer.transform(style: style)
        let sources = transformed["sources"] as? [String: [String: Any]]
        
        #expect(sources?["jpg-source"]?["tiles"] as? [String] == ["\(baseURL)/offline/\(packName)/tiles/jpg-source/{z}/{x}/{y}.jpg"])
        #expect(sources?["webp-source"]?["tiles"] as? [String] == ["\(baseURL)/offline/\(packName)/tiles/webp-source/{z}/{x}/{y}.webp"])
        #expect(sources?["dem-source"]?["tiles"] as? [String] == ["\(baseURL)/offline/\(packName)/tiles/dem-source/{z}/{x}/{y}.png"])
    }

    @Test("Transform style with mixed multiple sprites")
    func testTransformMultipleSprites() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let style: [String: Any] = [
            "sprite": [
                ["id": "default", "url": "https://api.maptiler.com/sprite1"],
                ["id": "theme", "url": "https://api.maptiler.com/sprite2"],
                ["url": "https://api.maptiler.com/sprite3"] // No ID
            ]
        ]
        
        let transformed = transformer.transform(style: style)
        let sprites = transformed["sprite"] as? [[String: Any]]
        
        #expect(sprites?.count == 3)
        #expect(sprites?[0]["url"] as? String == "\(baseURL)/offline/\(packName)/sprite")
        #expect(sprites?[1]["url"] as? String == "\(baseURL)/offline/\(packName)/sprite-theme")
        #expect(sprites?[2]["url"] as? String == "\(baseURL)/offline/\(packName)/sprite")
    }

    @Test("Sprite URL rewriting provides correct base URL for scale variants")
    func testSpriteBaseURLRewriting() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let style: [String: Any] = [
            "version": 8,
            "sprite": "https://api.maptiler.com/fonts/v1/sprite"
        ]
        
        let transformed = transformer.transform(style: style)
        
        // MapLibre will automatically append `.json`, `.png`, `@2x.json`, and `@2x.png` to this URL.
        // Thus, the rewritten URL must NOT have an extension.
        guard let rewrittenSpriteURL = transformed["sprite"] as? String else {
            Issue.record("Sprite URL was not rewritten correctly as a string.")
            return
        }
        
        #expect(rewrittenSpriteURL == "\(baseURL)/offline/\(packName)/sprite")
        #expect(!rewrittenSpriteURL.hasSuffix(".json"))
        #expect(!rewrittenSpriteURL.hasSuffix(".png"))
        
        // Simulating the renderer's behavior to ensure the resulting constructed URLs are correct
        let jsonURL1x = rewrittenSpriteURL + ".json"
        let pngURL1x = rewrittenSpriteURL + ".png"
        let jsonURL2x = rewrittenSpriteURL + "@2x.json"
        let pngURL2x = rewrittenSpriteURL + "@2x.png"
        
        #expect(jsonURL1x == "\(baseURL)/offline/\(packName)/sprite.json")
        #expect(pngURL1x == "\(baseURL)/offline/\(packName)/sprite.png")
        #expect(jsonURL2x == "\(baseURL)/offline/\(packName)/sprite@2x.json")
        #expect(pngURL2x == "\(baseURL)/offline/\(packName)/sprite@2x.png")
    }

    @Test("Purging maptiler_attribution source and its layers")
    func testPurgingAttributionSourceAndLayers() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let style: [String: Any] = [
            "version": 8,
            "sources": [
                "maptiler_attribution": [
                    "type": "vector",
                    "url": "https://api.maptiler.com/tiles/v3/tiles.json"
                ],
                "valid-source": [
                    "type": "raster",
                    "tiles": ["https://api.maptiler.com/raster"]
                ]
            ],
            "layers": [
                [
                    "id": "attribution-layer",
                    "type": "symbol",
                    "source": "maptiler_attribution"
                ],
                [
                    "id": "background",
                    "type": "background" // No source
                ],
                [
                    "id": "valid-layer",
                    "type": "raster",
                    "source": "valid-source"
                ]
            ]
        ]
        
        let transformed = transformer.transform(style: style)
        
        let sources = transformed["sources"] as? [String: Any]
        #expect(sources != nil)
        #expect(sources?["maptiler_attribution"] == nil)
        #expect(sources?["valid-source"] != nil)
        
        let layers = transformed["layers"] as? [[String: Any]]
        #expect(layers?.count == 2)
        #expect(layers?[0]["id"] as? String == "background")
        #expect(layers?[1]["id"] as? String == "valid-layer")
    }
    
    @Test("Processor handles empty or minimal style gracefully")
    func testEmptyStyle() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let style: [String: Any] = [:]
        let transformed = transformer.transform(style: style)
        
        #expect(transformed.isEmpty)
        
        let minimalStyle: [String: Any] = ["version": 8, "name": "Minimal"]
        let transformedMinimal = transformer.transform(style: minimalStyle)
        #expect(transformedMinimal["version"] as? Int == 8)
        #expect(transformedMinimal["name"] as? String == "Minimal")
    }

    @Test("Glyphs URL template is correctly rewritten preserving placeholders")
    func testGlyphsURLRewriting() {
        let transformer = MTStyleProcessor(baseURL: baseURL, packName: packName)
        
        let originalGlyphsURL = "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf?key=my_api_key"
        let style: [String: Any] = [
            "version": 8,
            "glyphs": originalGlyphsURL
        ]
        
        let transformed = transformer.transform(style: style)
        
        guard let rewrittenGlyphsURL = transformed["glyphs"] as? String else {
            Issue.record("Glyphs URL was not rewritten correctly.")
            return
        }
        
        // The expected local template format
        let expectedTemplate = "\(baseURL)/offline/\(packName)/glyphs/{fontstack}/{range}.pbf"
        
        #expect(rewrittenGlyphsURL == expectedTemplate)
        
        // Verify mandatory tokens are preserved
        #expect(rewrittenGlyphsURL.contains("{fontstack}"))
        #expect(rewrittenGlyphsURL.contains("{range}"))
        
        // Simulate a round-trip substitution by the map renderer
        let resolvedLocalURL = rewrittenGlyphsURL
            .replacingOccurrences(of: "{fontstack}", with: "Noto Sans Regular")
            .replacingOccurrences(of: "{range}", with: "0-255")
            
        #expect(resolvedLocalURL == "\(baseURL)/offline/\(packName)/glyphs/Noto Sans Regular/0-255.pbf")
    }
}
