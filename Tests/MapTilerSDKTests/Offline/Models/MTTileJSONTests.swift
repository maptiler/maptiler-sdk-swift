//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite
struct MTTileJSONTests {
    
    @Test func decodeFullTileJSON() throws {
        let json = """
        {
            "tiles": ["https://example.com/{z}/{x}/{y}.pbf"],
            "scheme": "xyz",
            "bounds": [-180, -85.05112877980659, 180, 85.0511287798066],
            "minzoom": 2,
            "maxzoom": 14,
            "tileSize": 512
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.tiles == ["https://example.com/{z}/{x}/{y}.pbf"])
        #expect(tileJSON.scheme == .xyz)
        #expect(tileJSON.bounds == [-180, -85.05112877980659, 180, 85.0511287798066])
        #expect(tileJSON.minzoom == 2)
        #expect(tileJSON.maxzoom == 14)
        #expect(tileJSON.tileSize == 512)
    }
    
    @Test func decodeMinimalTileJSON() throws {
        let json = """
        {
            "tiles": ["https://example.com/tiles/{z}/{x}/{y}.png"]
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.tiles == ["https://example.com/tiles/{z}/{x}/{y}.png"])
        #expect(tileJSON.scheme == .xyz)
        #expect(tileJSON.bounds == nil)
        #expect(tileJSON.minzoom == 0)
        #expect(tileJSON.maxzoom == 30)
        #expect(tileJSON.tileSize == 256)
    }
    
    @Test func decodeTileJSONWithSnakeCaseTileSize() throws {
        let json = """
        {
            "tiles": ["https://example.com/{z}/{x}/{y}.pbf"],
            "tile_size": 1024
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.tileSize == 1024)
    }

    @Test func decodeTileJSONWithNoUnderscoreTileSize() throws {
        let json = """
        {
            "tiles": ["https://example.com/{z}/{x}/{y}.pbf"],
            "tilesize": 512
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.tileSize == 512)
    }

    @Test func decodeTileJSONWithMissingTileSizeDefaultsTo256() throws {
        let json = """
        {
            "tiles": ["https://example.com/{z}/{x}/{y}.pbf"]
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.tileSize == 256)
    }

    @Test func decodeTileJSONWithTMSSchemeMixedCase() throws {
        let json = """
        {
            "tiles": ["https://example.com/{z}/{x}/{y}.pbf"],
            "scheme": "tMs"
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.scheme == .tms)
    }

    @Test func decodeTileJSONWithXYZSchemeMixedCase() throws {
        let json = """
        {
            "tiles": ["https://example.com/{z}/{x}/{y}.pbf"],
            "scheme": "XyZ"
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.scheme == .xyz)
    }

    @Test func decodeTileJSONWithInvalidSchemeDefaultsToXYZ() throws {
        let json = """
        {
            "tiles": ["https://example.com/{z}/{x}/{y}.pbf"],
            "scheme": "invalid-scheme"
        }
        """
        
        let data = Data(json.utf8)
        let tileJSON = try JSONDecoder().decode(MTTileJSON.self, from: data)
        
        #expect(tileJSON.scheme == .xyz)
    }
    
    @Test func encodeTileJSON() throws {
        let tileJSON = MTTileJSON(
            tiles: ["https://example.com/{z}/{x}/{y}.pbf"],
            scheme: .tms,
            bounds: [-10, -10, 10, 10],
            minzoom: 5,
            maxzoom: 10,
            tileSize: 512
        )
        
        let data = try JSONEncoder().encode(tileJSON)
        
        if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            #expect(jsonObject["tiles"] as? [String] == ["https://example.com/{z}/{x}/{y}.pbf"])
            #expect(jsonObject["scheme"] as? String == "tms")
            #expect(jsonObject["bounds"] as? [Double] == [-10, -10, 10, 10])
            #expect(jsonObject["minzoom"] as? Int == 5)
            #expect(jsonObject["maxzoom"] as? Int == 10)
            #expect(jsonObject["tileSize"] as? Int == 512)
        } else {
            Issue.record("Failed to serialize encoded JSON")
        }
    }
}
