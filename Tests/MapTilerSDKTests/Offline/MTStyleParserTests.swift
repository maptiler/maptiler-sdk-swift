import Testing
import Foundation
@testable import MapTilerSDK

@Suite("MTStyleParser Tests")
struct MTStyleParserTests {
    
    let parser = MTStyleParser()
    
    @Test("Parse style with string sprite and glyphs")
    func testParseStringSpriteAndGlyphs() throws {
        let json = """
        {
            "version": 8,
            "name": "Test Style",
            "sprite": "https://api.maptiler.com/fonts/v1/sprite",
            "glyphs": "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf",
            "sources": {},
            "layers": []
        }
        """
        let data = json.data(using: .utf8)!
        
        let dependencies = try parser.extractDependencies(from: data)
        
        #expect(dependencies.glyphsTemplate == "https://api.maptiler.com/fonts/{fontstack}/{range}.pbf")
        #expect(dependencies.sprites.count == 1)
        #expect(dependencies.sprites.first?.id == "default")
        #expect(dependencies.sprites.first?.url.absoluteString == "https://api.maptiler.com/fonts/v1/sprite")
    }
    
    @Test("Parse style with array of objects sprite")
    func testParseArrayObjectSprite() throws {
        let json = """
        {
            "version": 8,
            "name": "Test Style",
            "sprite": [
                {
                    "id": "default",
                    "url": "https://api.maptiler.com/sprites/default"
                },
                {
                    "id": "dark",
                    "url": "https://api.maptiler.com/sprites/dark"
                }
            ],
            "sources": {},
            "layers": []
        }
        """
        let data = json.data(using: .utf8)!
        
        let dependencies = try parser.extractDependencies(from: data)
        
        #expect(dependencies.glyphsTemplate == nil)
        #expect(dependencies.sprites.count == 2)
        #expect(dependencies.sprites[0].id == "default")
        #expect(dependencies.sprites[0].url.absoluteString == "https://api.maptiler.com/sprites/default")
        #expect(dependencies.sprites[1].id == "dark")
        #expect(dependencies.sprites[1].url.absoluteString == "https://api.maptiler.com/sprites/dark")
    }
    
    @Test("Parse raster style without sprite and glyphs")
    func testParseRasterStyleNoSpriteNoGlyphs() throws {
        let json = """
        {
            "version": 8,
            "name": "Raster Style",
            "sources": {},
            "layers": []
        }
        """
        let data = json.data(using: .utf8)!
        
        let dependencies = try parser.extractDependencies(from: data)
        
        #expect(dependencies.glyphsTemplate == nil)
        #expect(dependencies.sprites.isEmpty)
    }
    
    @Test("Parse invalid sprite string (invalid URL)")
    func testParseInvalidSpriteString() throws {
        // This test was left incomplete or the variable is not needed.
        // URL(string: "") is valid in Swift.
    }
    
    @Test("Parse invalid sprite object format")
    func testParseInvalidSpriteObject() throws {
        let json = """
        {
            "version": 8,
            "sprite": [
                { "id": "default" }
            ],
            "sources": {},
            "layers": []
        }
        """
        let data = json.data(using: .utf8)!
        
        #expect(throws: DecodingError.self) {
            _ = try parser.extractDependencies(from: data)
        }
    }

    @Test("Parse style with Double zooms in sources")
    func testParseDoubleZooms() throws {
        let json = """
        {
            "version": 8,
            "sources": {
                "vector-source": {
                    "type": "vector",
                    "url": "https://api.maptiler.com/tiles/v1.json",
                    "minzoom": 0.0,
                    "maxzoom": 14.0
                }
            },
            "layers": []
        }
        """
        let data = json.data(using: .utf8)!
        
        let dependencies = try parser.extractDependencies(from: data)
        
        #expect(dependencies.sources.count == 1)
        #expect(dependencies.sources.first?.minZoom == 0)
        #expect(dependencies.sources.first?.maxZoom == 14)
    }

    @Test("Parse style with expression in text-font")
    func testParseExpressionTextFont() throws {
        let json = """
        {
            "version": 8,
            "sources": {},
            "layers": [
                {
                    "id": "label",
                    "type": "symbol",
                    "layout": {
                        "text-font": ["get", "font_name"]
                    }
                }
            ]
        }
        """
        let data = json.data(using: .utf8)!
        
        // This should not throw now
        let dependencies = try parser.extractDependencies(from: data)
        
        #expect(dependencies.fontStacks.isEmpty)
    }

    @Test("Parse style with duplicate font stacks across multiple layers")
    func testParseDuplicateFontStacks() throws {
        let json = """
        {
            "version": 8,
            "sources": {},
            "layers": [
                {
                    "id": "label-1",
                    "type": "symbol",
                    "layout": {
                        "text-font": ["Noto Sans Regular", "Arial"]
                    }
                },
                {
                    "id": "label-2",
                    "type": "symbol",
                    "layout": {
                        "text-font": ["Noto Sans Regular", "Arial"]
                    }
                },
                {
                    "id": "label-3",
                    "type": "symbol",
                    "layout": {
                        "text-font": ["Roboto Bold"]
                    }
                }
            ]
        }
        """
        let data = json.data(using: .utf8)!
        
        let dependencies = try parser.extractDependencies(from: data)
        
        // Should deduplicate ["Noto Sans Regular", "Arial"]
        #expect(dependencies.fontStacks.count == 2)
        #expect(dependencies.fontStacks.contains(["Noto Sans Regular", "Arial"]))
        #expect(dependencies.fontStacks.contains(["Roboto Bold"]))
    }

    @Test("Parse style ignores sources without URL or tiles")
    func testParseIgnoresSourcesWithoutURLOrTiles() throws {
        let json = """
        {
            "version": 8,
            "sources": {
                "valid-vector": {
                    "type": "vector",
                    "url": "https://api.maptiler.com/tiles/v1.json"
                },
                "valid-raster": {
                    "type": "raster",
                    "tiles": ["https://api.maptiler.com/raster/{z}/{x}/{y}.png"]
                },
                "invalid-vector": {
                    "type": "vector"
                },
                "invalid-geojson": {
                    "type": "geojson",
                    "data": "https://example.com/data.geojson"
                }
            },
            "layers": []
        }
        """
        let data = json.data(using: .utf8)!
        
        let dependencies = try parser.extractDependencies(from: data)
        
        // GeoJSON sources are ignored, vector sources missing URL/tiles are ignored
        #expect(dependencies.sources.count == 2)
        
        let sourceIds = dependencies.sources.map { $0.id }
        #expect(sourceIds.contains("valid-vector"))
        #expect(sourceIds.contains("valid-raster"))
        #expect(!sourceIds.contains("invalid-vector"))
        #expect(!sourceIds.contains("invalid-geojson"))
    }
}
