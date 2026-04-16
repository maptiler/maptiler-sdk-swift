//
//  MTSyntheticManifestTests.swift
//  MapTilerSDKTests
//

import XCTest
@testable import MapTilerSDK

final class MTSyntheticManifestTests: XCTestCase {

    func testManifestSerializationAndDeserialization() throws {
        // 1. Arrange
        let builder = MTSyntheticManifest(style: "style.json")
        
        let spriteSet = MTSpriteSet(baseName: "sprite", scale: 2, files: ["sprite@2x.json", "sprite@2x.png"])
        builder.addSpriteSet(spriteSet)
        
        let glyphSet = MTGlyphSet(fontStack: "Noto Sans Regular", ranges: ["0-255.pbf"])
        builder.addGlyphSet(glyphSet)
        
        let tileSource = MTSyntheticTileSource(type: .vector, tileKeys: ["0/0/0.pbf", "1/0/0.pbf"])
        builder.addTileSource(id: "maptiler-planet", source: tileSource)
        
        // 2. Act (Serialize)
        let jsonData = try builder.toJSONData()
        
        // Check the string output optionally
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("\"version\" : \"1\""))
        XCTAssertTrue(jsonString!.contains("\"style\" : \"style.json\""))
        XCTAssertTrue(jsonString!.contains("\"base_name\" : \"sprite\""))
        XCTAssertTrue(jsonString!.contains("\"font_stack\" : \"Noto Sans Regular\""))
        XCTAssertTrue(jsonString!.contains("\"tile_keys\" : ["))
        
        // 3. Act (Deserialize)
        let decodedManifest = try MTSyntheticManifest.fromJSONData(jsonData)
        
        // 4. Assert
        XCTAssertEqual(decodedManifest.manifest.version, "1")
        XCTAssertEqual(decodedManifest.manifest.style, "style.json")
        
        XCTAssertEqual(decodedManifest.manifest.sprites.count, 1)
        XCTAssertEqual(decodedManifest.manifest.sprites[0].baseName, "sprite")
        XCTAssertEqual(decodedManifest.manifest.sprites[0].scale, 2)
        XCTAssertEqual(decodedManifest.manifest.sprites[0].files, ["sprite@2x.json", "sprite@2x.png"])
        
        XCTAssertEqual(decodedManifest.manifest.glyphs.count, 1)
        XCTAssertEqual(decodedManifest.manifest.glyphs[0].fontStack, "Noto Sans Regular")
        XCTAssertEqual(decodedManifest.manifest.glyphs[0].ranges, ["0-255.pbf"])
        
        XCTAssertEqual(decodedManifest.manifest.tiles.count, 1)
        XCTAssertNotNil(decodedManifest.manifest.tiles["maptiler-planet"])
        XCTAssertEqual(decodedManifest.manifest.tiles["maptiler-planet"]?.type, .vector)
        XCTAssertEqual(decodedManifest.manifest.tiles["maptiler-planet"]?.tileKeys, ["0/0/0.pbf", "1/0/0.pbf"])
        
        // Full equality
        XCTAssertEqual(builder.manifest, decodedManifest.manifest)
    }
    
    func testUnsupportedVersionThrowsError() throws {
        let invalidJson = """
        {
            "version": "2",
            "style": "style.json"
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try MTSyntheticManifest.fromJSONData(invalidJson)) { error in
            guard let manifestError = error as? MTSyntheticManifestError else {
                XCTFail("Expected MTSyntheticManifestError, got \(error)")
                return
            }
            XCTAssertEqual(manifestError, .unsupportedVersion("2"))
        }
    }
}
