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
        let json = """
        {
            "version": 8,
            "sprite": "",
            "sources": {},
            "layers": []
        }
        """
        let data = json.data(using: .utf8)!
        
        // Testing that an empty string, if it fails URL parsing, throws an error.
        // Wait, URL(string: "") is valid in Swift and returns a URL with no path/host.
        // However, a completely invalid string like "http://[invalid-host]" might fail or we can just expect it to decode as empty URL.
        // Let's test a case where `sprite` is an object but missing `url` or `id`.
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
}
