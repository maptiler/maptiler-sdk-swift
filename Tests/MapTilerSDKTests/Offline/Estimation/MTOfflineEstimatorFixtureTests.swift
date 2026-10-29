import Testing
import Foundation
import CoreLocation
@testable import MapTilerSDK

// Runs the shared estimator fixtures (maptiler-offline-estimator/fixtures) that every platform must agree on.
//
// Each case is checked three ways: against the expected counts in the fixture, against the set-based reference
// implementation the planner used before, and against the number of resources the planner puts in the manifest.
@Suite("MTOfflineEstimator Fixture Tests")
struct MTOfflineEstimatorFixtureTests {

    @Test("Estimates match the shared fixtures", arguments: OfflineEstimatorFixtures.load().cases)
    func testFixture(_ fixtureCase: OfflineEstimatorFixtures.Case) throws {
        let fixtures = OfflineEstimatorFixtures.load()
        let metadata = try #require(fixtures.metadata[fixtureCase.metadata])
        let region = fixtureCase.region.definition

        let stats = try MTOfflineEstimator().estimatePack(region: region, styleMetadata: metadata)
        let actual = OfflineEstimatorFixtures.Expected(stats: stats)

        let reference = referenceCounts(region: region, metadata: metadata)
        #expect(actual == reference, "\(fixtureCase.name): estimator differs from the reference implementation")

        let expected = try #require(
            fixtures.expected[fixtureCase.name],
            "\(fixtureCase.name): missing expected counts, computed: \(reference.jsonString)"
        )
        #expect(actual == expected, "\(fixtureCase.name): expected \(expected.jsonString), got \(actual.jsonString)")

        // The manifest must contain exactly the estimated resources, without duplicates.
        let plan = try MTOfflineResourcePlan(definition: region, metadata: metadata)
        let tiles = plan.tileResources()
        #expect(tiles.count == stats.tileCount)
        #expect(Set(tiles.map(\.destinationPath)).count == tiles.count)
        #expect(plan.glyphResources().count == stats.glyphCount)
        #expect(plan.spriteResources().count == stats.spriteCount)
    }

    // Counts computed with the set-based tile helpers, following the planner's original resource rules.
    private func referenceCounts(
        region: MTOfflineRegionDefinition,
        metadata: MTOfflineStyleMetadata
    ) -> OfflineEstimatorFixtures.Expected {
        var sources = metadata.sources
        if region.isTerrainEnabled, !sources.contains(where: { $0.type == "raster-dem" }), let terrain = metadata.terrainSource {
            sources.append(terrain)
        }
        let isFlexible: Bool = {
            if case .boundingBox = region.geometry { return false }
            return true
        }()
        let paddingMeters = region.padding ?? (isFlexible ? 2000.0 : nil)

        var tilesPerSource: [String: OfflineEstimatorFixtures.SourceCounts] = [:]
        for source in sources {
            var effectiveMin = max(region.minZoom, source.minZoom)
            var effectiveMax = min(region.maxZoom, source.maxZoom)
            if region.minZoom > source.maxZoom {
                effectiveMin = source.maxZoom
                effectiveMax = source.maxZoom
            }
            guard effectiveMin <= effectiveMax else { continue }

            var tilesPerZoom: [String: Int] = [:]
            for zoom in effectiveMin...effectiveMax {
                if case .boundingBox(let bbox) = region.geometry {
                    var tiles = Set<MTTileIndex>()
                    for box in bbox.normalizedAndSplit() {
                        let ranges = MTTileMath.tileRanges(for: box, zoom: zoom, paddingMeters: paddingMeters)
                        for x in ranges.x {
                            for y in ranges.y {
                                tiles.insert(MTTileIndex(x: x, y: y, z: zoom))
                            }
                        }
                    }
                    tilesPerZoom[String(zoom)] = tiles.count
                } else {
                    tilesPerZoom[String(zoom)] = MTTileMath.tiles(
                        for: region.geometry,
                        zoom: zoom,
                        paddingMeters: paddingMeters
                    ).count
                }
            }
            tilesPerSource[source.id] = .init(minZoom: effectiveMin, maxZoom: effectiveMax, tilesPerZoom: tilesPerZoom)
        }

        let glyphs = metadata.glyphsTemplate == nil ? 0 : metadata.fontStacks.count * region.glyphRanges.rangeStarts.count
        let sprites = metadata.sprites.count * 4
        let tiles = tilesPerSource.values.reduce(0) { $0 + $1.tilesPerZoom.values.reduce(0, +) }
        return .init(sources: tilesPerSource, glyphs: glyphs, sprites: sprites, style: 1, total: tiles + glyphs + sprites + 1)
    }
}

// MARK: - Fixture model

struct OfflineEstimatorFixtures: Decodable {
    struct Geometry: Decodable {
        let type: String
        let bbox: [Double]?
        let coordinates: [[Double]]?

        var geometry: MTOfflineRegionGeometry {
            let points = (coordinates ?? []).map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0]) }
            switch type {
            case "bbox":
                let b = bbox ?? []
                return .boundingBox(MTBoundingBox(minLon: b[0], minLat: b[1], maxLon: b[2], maxLat: b[3]))
            case "polygon":
                return .polygon(points)
            default:
                return .route(points)
            }
        }
    }

    struct Region: Decodable {
        let geometry: Geometry
        let minZoom: Int
        let maxZoom: Int
        let padding: Double?
        let terrain: Bool?
        let maxTileCount: Int?
        // "all", "latinGreekCyrillic" (default) or a list of range start code points.
        let glyphRanges: GlyphRanges?

        enum GlyphRanges: Decodable {
            case named(String)
            case starts([Int])

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let name = try? container.decode(String.self) {
                    self = .named(name)
                } else {
                    self = .starts(try container.decode([Int].self))
                }
            }

            var value: MTOfflineGlyphRanges {
                switch self {
                case .named("all"): return .all
                case .named: return .latinGreekCyrillic
                case .starts(let starts): return .custom(starts)
                }
            }
        }

        var definition: MTOfflineRegionDefinition {
            MTOfflineRegionDefinition(
                geometry: geometry.geometry,
                minZoom: minZoom,
                maxZoom: maxZoom,
                referenceStyle: .streets,
                maxTileCount: maxTileCount,
                padding: padding,
                isTerrainEnabled: terrain ?? false,
                glyphRanges: glyphRanges?.value ?? .latinGreekCyrillic
            )
        }
    }

    struct Case: Decodable, CustomTestStringConvertible {
        let name: String
        let metadata: String
        let region: Region

        var testDescription: String { name }
    }

    struct SourceCounts: Codable, Equatable {
        let minZoom: Int
        let maxZoom: Int
        let tilesPerZoom: [String: Int]
    }

    struct Expected: Codable, Equatable {
        let sources: [String: SourceCounts]
        let glyphs: Int
        let sprites: Int
        let style: Int
        let total: Int

        init(sources: [String: SourceCounts], glyphs: Int, sprites: Int, style: Int, total: Int) {
            self.sources = sources
            self.glyphs = glyphs
            self.sprites = sprites
            self.style = style
            self.total = total
        }

        init(stats: MTPackStats) {
            var sources: [String: SourceCounts] = [:]
            for source in stats.sources {
                sources[source.id] = SourceCounts(
                    minZoom: source.minZoom,
                    maxZoom: source.maxZoom,
                    tilesPerZoom: Dictionary(uniqueKeysWithValues: source.tilesPerZoom.map { (String($0.key), $0.value) })
                )
            }
            self.init(
                sources: sources,
                glyphs: stats.glyphCount,
                sprites: stats.spriteCount,
                style: stats.styleCount,
                total: stats.resourceCount
            )
        }

        var jsonString: String {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            return (try? encoder.encode(self)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        }
    }

    struct Expectations: Decodable {
        let cases: [String: Expected]
    }

    let metadata: [String: MTOfflineStyleMetadata]
    let cases: [Case]
    var expected: [String: Expected] = [:]

    enum CodingKeys: String, CodingKey {
        case metadata, cases
    }

    static func load() -> OfflineEstimatorFixtures {
        let decoder = JSONDecoder()
        guard let fixturesURL = Bundle.module.url(
                forResource: "offline-estimator-fixtures",
                withExtension: "json",
                subdirectory: "Fixtures"
            ),
            let expectedURL = Bundle.module.url(
                forResource: "offline-estimator-expected",
                withExtension: "json",
                subdirectory: "Fixtures"
            ),
            var fixtures = try? decoder.decode(OfflineEstimatorFixtures.self, from: Data(contentsOf: fixturesURL)) else {
            fatalError("Offline estimator fixtures are missing from the test bundle")
        }
        fixtures.expected = (try? decoder.decode(Expectations.self, from: Data(contentsOf: expectedURL)))?.cases ?? [:]
        return fixtures
    }
}
