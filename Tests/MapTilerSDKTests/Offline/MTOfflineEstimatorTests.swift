import Testing
import Foundation
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflineEstimator Tests")
struct MTOfflineEstimatorTests {

    // Registers a style with one vector source (TileJSON, zoom 0-14), one raster source with inline tiles,
    // two font stacks and one sprite on a host unique to the calling test. Returns the style URL.
    private func registerStyle(host: String) -> URL {
        let base = "https://\(host)"
        EstimationMockURLProtocol.register("\(base)/style.json", json: """
        {
          "version": 8,
          "sprite": "\(base)/sprite",
          "glyphs": "\(base)/fonts/{fontstack}/{range}.pbf",
          "sources": {
            "planet": { "type": "vector", "url": "\(base)/planet/tiles.json" },
            "hillshade": { "type": "raster", "tiles": ["\(base)/hillshade/{z}/{x}/{y}.png"], "minzoom": 2, "maxzoom": 12 }
          },
          "layers": [
            { "id": "a", "type": "symbol", "source": "planet", "layout": { "text-font": ["Noto Sans Regular"] } },
            { "id": "b", "type": "symbol", "source": "planet", "layout": { "text-font": ["Noto Sans Bold"] } }
          ]
        }
        """)
        EstimationMockURLProtocol.register("\(base)/planet/tiles.json", json: """
        { "tiles": ["\(base)/planet/{z}/{x}/{y}.pbf"], "minzoom": 0, "maxzoom": 14 }
        """)
        return URL(string: "\(base)/style.json")!
    }

    private func region(
        styleURL: URL,
        minZoom: Int = 0,
        maxZoom: Int = 16,
        terrain: Bool = false,
        maxTileCount: Int? = nil
    ) -> MTOfflineRegionDefinition {
        MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.52, minLat: 47.36, maxLon: 8.56, maxLat: 47.39),
            minZoom: minZoom,
            maxZoom: maxZoom,
            referenceStyle: .custom(styleURL),
            maxTileCount: maxTileCount,
            isTerrainEnabled: terrain
        )
    }

    @Test("Estimate fetches only style and TileJSON and matches the manifest")
    func testEstimateMatchesManifestWithoutTileRequests() async throws {
        let host = "estimate-manifest.test"
        let styleURL = registerStyle(host: host)
        let resolver = MTOfflineMetadataResolver(session: EstimationMockURLProtocol.makeSession())
        let definition = region(styleURL: styleURL)

        let stats = try await MTOfflineEstimator(resolver: resolver).estimatePack(region: definition)

        #expect(EstimationMockURLProtocol.requests(toHost: host) == [
            "https://\(host)/style.json",
            "https://\(host)/planet/tiles.json"
        ])

        // Vector tiles stop at the TileJSON max zoom, raster tiles at the style's source max zoom.
        let planet = try #require(stats.sources.first { $0.id == "planet" })
        #expect(planet.minZoom == 0 && planet.maxZoom == 14)
        let hillshade = try #require(stats.sources.first { $0.id == "hillshade" })
        #expect(hillshade.minZoom == 2 && hillshade.maxZoom == 12)

        #expect(stats.glyphCount == 2 * MTOfflineGlyphRanges.latinGreekCyrillicStarts.count)
        #expect(stats.spriteCount == 4)
        #expect(stats.styleCount == 1)
        #expect(stats.resourceCount == stats.tileCount + stats.glyphCount + stats.spriteCount + 1)

        let planner = MTLocalPlanner(session: EstimationMockURLProtocol.makeSession())
        let manifest = try await planner.generateManifest(for: definition)
        let manifestCount = manifest.tiles.count + manifest.glyphs.count + manifest.sprites.count + 1
        #expect(manifestCount == stats.resourceCount)
        #expect(manifest.tiles.count == stats.tileCount)
    }

    @Test("Resolved metadata is cached and reused")
    func testMetadataCache() async throws {
        let host = "estimate-cache.test"
        let styleURL = registerStyle(host: host)
        let resolver = MTOfflineMetadataResolver(session: EstimationMockURLProtocol.makeSession())
        let estimator = MTOfflineEstimator(resolver: resolver)

        _ = try await estimator.estimatePack(region: region(styleURL: styleURL, maxZoom: 10))
        _ = try await estimator.estimatePack(region: region(styleURL: styleURL, minZoom: 5, maxZoom: 14))

        #expect(EstimationMockURLProtocol.requests(toHost: host).count == 2)
    }

    @Test("Estimate with stored metadata makes no requests")
    func testEstimateWithMetadataIsOffline() async throws {
        let host = "estimate-offline.test"
        let styleURL = registerStyle(host: host)
        let estimator = MTOfflineEstimator(resolver: MTOfflineMetadataResolver(session: EstimationMockURLProtocol.makeSession()))
        let metadata = try await estimator.styleMetadata(for: region(styleURL: styleURL))
        let requestsAfterResolve = EstimationMockURLProtocol.requests(toHost: host).count

        let decoded = try JSONDecoder().decode(MTOfflineStyleMetadata.self, from: JSONEncoder().encode(metadata))
        #expect(decoded == metadata)

        let online = try await estimator.estimatePack(region: region(styleURL: styleURL))
        let offline = try MTOfflineEstimator().estimatePack(region: region(styleURL: styleURL), styleMetadata: decoded)
        #expect(offline.resourceCount == online.resourceCount)
        #expect(offline.sources == online.sources)
        #expect(EstimationMockURLProtocol.requests(toHost: host).count == requestsAfterResolve)
    }

    @Test("Redacted metadata has no API keys or session ids and estimates the same")
    func testRedactedMetadata() throws {
        let source = { (id: String, template: String) in
            MTOfflineSourceMetadata(id: id, type: .vector, tileURLTemplate: template, minZoom: 0, maxZoom: 14)
        }
        let metadata = MTOfflineStyleMetadata(
            styleURL: "https://t/maps/streets/style.json?key=SECRET",
            sources: [source("v", "https://t/tiles/{z}/{x}/{y}.pbf?key=SECRET&mtsid=SESSION")],
            terrainSource: source("terrain", "https://t/terrain/{z}/{x}/{y}.webp?mtsid=SESSION&key=SECRET&v=2"),
            glyphsTemplate: "https://t/fonts/{fontstack}/{range}.pbf?key=SECRET",
            fontStacks: [["Noto Sans Regular"]],
            sprites: [MTOfflineSpriteMetadata(id: "default", url: "https://t/maps/streets/sprite?key=SECRET")]
        )

        let redacted = metadata.redacted()
        #expect(redacted.styleURL == "https://t/maps/streets/style.json")
        #expect(redacted.sources[0].tileURLTemplate == "https://t/tiles/{z}/{x}/{y}.pbf")
        #expect(redacted.terrainSource?.tileURLTemplate == "https://t/terrain/{z}/{x}/{y}.webp?v=2")
        #expect(redacted.glyphsTemplate == "https://t/fonts/{fontstack}/{range}.pbf")
        #expect(redacted.sprites[0].url == "https://t/maps/streets/sprite")

        let encoded = try #require(String(data: JSONEncoder().encode(redacted), encoding: .utf8))
        #expect(!encoded.contains("SECRET"))
        #expect(!encoded.contains("SESSION"))

        let definition = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.53, minLat: 47.37, maxLon: 8.55, maxLat: 47.38),
            minZoom: 0,
            maxZoom: 14,
            referenceStyle: .streets,
            isTerrainEnabled: true
        )
        let estimator = MTOfflineEstimator()
        let original = try estimator.estimatePack(region: definition, styleMetadata: metadata)
        let stored = try estimator.estimatePack(region: definition, styleMetadata: redacted)
        #expect(stored.resourceCount == original.resourceCount)
        #expect(stored.sources == original.sources)
    }

    @Test("Requests above the source max zoom download the source max zoom")
    func testOverzoom() throws {
        let metadata = MTOfflineStyleMetadata(
            styleURL: nil,
            sources: [MTOfflineSourceMetadata(id: "v", type: .vector, tileURLTemplate: "https://t/{z}/{x}/{y}.pbf", minZoom: 0, maxZoom: 14)],
            glyphsTemplate: nil,
            fontStacks: [],
            sprites: []
        )
        let definition = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.53, minLat: 47.37, maxLon: 8.55, maxLat: 47.38),
            minZoom: 16,
            maxZoom: 18,
            referenceStyle: .streets
        )
        let stats = try MTOfflineEstimator().estimatePack(region: definition, styleMetadata: metadata)
        #expect(stats.sources.first?.minZoom == 14)
        #expect(stats.sources.first?.maxZoom == 14)
        #expect(stats.sources.first?.tilesPerZoom.keys.sorted() == [14])
    }

    @Test("Terrain adds a terrain source only when the style has none")
    func testTerrain() throws {
        let terrain = MTOfflineSourceMetadata(id: "maptiler-terrain", type: .rasterDEM, tileURLTemplate: "https://t/{z}/{x}/{y}.webp", minZoom: 0, maxZoom: 12)
        let vector = MTOfflineSourceMetadata(id: "v", type: .vector, tileURLTemplate: "https://t/{z}/{x}/{y}.pbf", minZoom: 0, maxZoom: 14)
        let definition = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.52, minLat: 47.36, maxLon: 8.56, maxLat: 47.39),
            minZoom: 0,
            maxZoom: 14,
            referenceStyle: .streets,
            isTerrainEnabled: true
        )

        let withTerrain = MTOfflineStyleMetadata(styleURL: nil, sources: [vector], terrainSource: terrain, glyphsTemplate: nil, fontStacks: [], sprites: [])
        let stats = try MTOfflineEstimator().estimatePack(region: definition, styleMetadata: withTerrain)
        #expect(stats.sources.map(\.id) == ["v", "maptiler-terrain"])

        let styleTerrain = MTOfflineSourceMetadata(id: "dem", type: .rasterDEM, tileURLTemplate: "https://t/{z}/{x}/{y}.webp", minZoom: 0, maxZoom: 12)
        let builtIn = MTOfflineStyleMetadata(styleURL: nil, sources: [vector, styleTerrain], terrainSource: terrain, glyphsTemplate: nil, fontStacks: [], sprites: [])
        #expect(try MTOfflineEstimator().estimatePack(region: definition, styleMetadata: builtIn).sources.map(\.id) == ["v", "dem"])

        let missing = MTOfflineStyleMetadata(styleURL: nil, sources: [vector], glyphsTemplate: nil, fontStacks: [], sprites: [])
        #expect(throws: MTOfflineError.self) {
            try MTOfflineEstimator().estimatePack(region: definition, styleMetadata: missing)
        }
    }

    @Test("Limit and minimum pack count")
    func testLimitAndPackCount() throws {
        let metadata = MTOfflineStyleMetadata(
            styleURL: nil,
            sources: [MTOfflineSourceMetadata(id: "v", type: .vector, tileURLTemplate: "https://t/{z}/{x}/{y}.pbf", minZoom: 0, maxZoom: 14)],
            glyphsTemplate: "https://t/{fontstack}/{range}.pbf",
            fontStacks: [["A"]],
            sprites: [MTOfflineSpriteMetadata(id: "default", url: "https://t/sprite")]
        )
        let definition = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.52, minLat: 47.36, maxLon: 8.56, maxLat: 47.39),
            minZoom: 0,
            maxZoom: 14,
            referenceStyle: .streets,
            maxTileCount: 500,
            glyphRanges: .all
        )
        let stats = try MTOfflineEstimator().estimatePack(region: definition, styleMetadata: metadata)

        #expect(stats.resourceLimit == 500)
        #expect(stats.exceedsLimit == (stats.resourceCount > 500))
        // 256 glyphs + 4 sprite files + 1 style leave 239 tiles per pack.
        let tileBudget = 500 - 261
        #expect(stats.minimumPackCount == (stats.tileCount + tileBudget - 1) / tileBudget)

        let tight = MTOfflineRegionDefinition(
            bbox: definition.bbox,
            minZoom: 0,
            maxZoom: 14,
            referenceStyle: .streets,
            maxTileCount: 200,
            glyphRanges: .all
        )
        #expect(try MTOfflineEstimator().estimatePack(region: tight, styleMetadata: metadata).minimumPackCount == nil)
    }

    @Test("Invalid regions are rejected")
    func testInvalidRegion() {
        let metadata = MTOfflineStyleMetadata(styleURL: nil, sources: [], glyphsTemplate: nil, fontStacks: [], sprites: [])
        let definition = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1),
            minZoom: 10,
            maxZoom: 5,
            referenceStyle: .streets
        )
        #expect(throws: MTOfflinePackError.invalidZoomRange) {
            try MTOfflineEstimator().estimatePack(region: definition, styleMetadata: metadata)
        }
    }
}

@Suite("MTOfflineGlyphRanges Tests")
struct MTOfflineGlyphRangesTests {
    private let metadata = MTOfflineStyleMetadata(
        styleURL: nil,
        sources: [MTOfflineSourceMetadata(id: "v", type: .vector, tileURLTemplate: "https://t/{z}/{x}/{y}.pbf", minZoom: 0, maxZoom: 14)],
        glyphsTemplate: "https://t/{fontstack}/{range}.pbf",
        fontStacks: [["A"], ["B", "C"]],
        sprites: []
    )

    private func region(_ glyphRanges: MTOfflineGlyphRanges) -> MTOfflineRegionDefinition {
        MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.52, minLat: 47.36, maxLon: 8.56, maxLat: 47.39),
            minZoom: 0,
            maxZoom: 10,
            referenceStyle: .streets,
            glyphRanges: glyphRanges
        )
    }

    @Test("Packs download Latin, Greek and Cyrillic ranges by default")
    func testDefaultRanges() throws {
        let definition = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 8.52, minLat: 47.36, maxLon: 8.56, maxLat: 47.39),
            minZoom: 0,
            maxZoom: 10,
            referenceStyle: .streets
        )
        #expect(definition.glyphRanges == .latinGreekCyrillic)

        let plan = try MTOfflineResourcePlan(definition: definition, metadata: metadata)
        let glyphs = plan.glyphResources()
        #expect(glyphs.count == 2 * 11)
        #expect(plan.glyphCount == glyphs.count)
        #expect(glyphs.contains { $0.destinationPath == "glyphs/A/1024-1279.pbf" })
        #expect(!glyphs.contains { $0.destinationPath == "glyphs/A/19968-20223.pbf" })
    }

    @Test("All and custom ranges")
    func testAllAndCustomRanges() throws {
        #expect(try MTOfflineResourcePlan(definition: region(.all), metadata: metadata).glyphCount == 2 * 256)

        let custom = MTOfflineGlyphRanges.custom([0, 300, 0x4E00, 0x4E10, -5, 70_000])
        #expect(custom.rangeStarts == [0, 256, 0x4E00])
        let plan = try MTOfflineResourcePlan(definition: region(custom), metadata: metadata)
        #expect(plan.glyphResources().map(\.destinationPath).contains("glyphs/B,C/19968-20223.pbf"))
        #expect(plan.glyphCount == 6)
    }

    @Test("Stored regions without glyph ranges keep downloading every range")
    func testDecodingLegacyDefinition() throws {
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(region(.latinGreekCyrillic))) as? [String: Any]
        json?.removeValue(forKey: "glyphRanges")
        let data = try JSONSerialization.data(withJSONObject: json ?? [:])
        #expect(try JSONDecoder().decode(MTOfflineRegionDefinition.self, from: data).glyphRanges == .all)

        let custom = region(.custom([0x4E00]))
        #expect(try JSONDecoder().decode(MTOfflineRegionDefinition.self, from: JSONEncoder().encode(custom)) == custom)
    }
}
