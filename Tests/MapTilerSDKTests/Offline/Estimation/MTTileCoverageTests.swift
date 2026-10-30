import Testing
import Foundation
import CoreLocation
@testable import MapTilerSDK

// Verifies that the interval-based coverage selects exactly the tiles of the set-based reference
// implementation in `MTTileMath`, which the planner used before.
@Suite("MTTileCoverage Tests")
struct MTTileCoverageTests {

    @Test("Bounding box coverage matches reference for random boxes")
    func testRandomBoundingBoxes() {
        var random = SeededRandom(seed: 1)
        for _ in 0..<300 {
            let zoom = random.int(in: 0...14)
            let span = random.double(in: 0.001...min(40.0, 2000.0 / pow(2.0, Double(zoom))))
            let minLon = random.double(in: -180...(180 - span))
            let minLat = random.double(in: -80...(80 - span))
            let bbox = MTBoundingBox(minLon: minLon, minLat: minLat, maxLon: minLon + span, maxLat: minLat + span)
            let padding = random.optionalPadding()

            let coverage = MTTileCoverage.make(for: .boundingBox(bbox), zoom: zoom, paddingMeters: padding)
            let reference = referenceBoundingBoxTiles(bbox, zoom: zoom, paddingMeters: padding)
            #expect(coverage.tileIndices() == reference, "bbox \(bbox) z\(zoom) padding \(String(describing: padding))")
            #expect(coverage.tileCount == reference.count)
        }
    }

    @Test("Antimeridian boxes do not count overlapping tiles twice")
    func testAntimeridianDeduplication() {
        let bbox = MTBoundingBox(minLon: 170, minLat: -20, maxLon: -170, maxLat: -10)
        for zoom in 0...6 {
            let coverage = MTTileCoverage.make(for: .boundingBox(bbox), zoom: zoom, paddingMeters: nil)
            let reference = referenceBoundingBoxTiles(bbox, zoom: zoom, paddingMeters: nil)
            #expect(coverage.tileIndices() == reference)
            #expect(coverage.tileCount == reference.count)
        }
        // At zoom 0 both halves cover the single world tile.
        #expect(MTTileCoverage.make(for: .boundingBox(bbox), zoom: 0, paddingMeters: nil).tileCount == 1)
    }

    @Test("Polygon coverage matches reference for random polygons")
    func testRandomPolygons() {
        var random = SeededRandom(seed: 2)
        for iteration in 0..<300 {
            let zoom = random.int(in: 0...13)
            let radius = random.double(in: 0.002...min(15.0, 600.0 / pow(2.0, Double(zoom))))
            let center = CLLocationCoordinate2D(
                latitude: random.double(in: -70...70),
                longitude: random.double(in: -160...160)
            )
            let vertexCount = random.int(in: 3...12)
            // Every third polygon has vertices in random order, which makes it self-intersecting.
            let ordered = iteration % 3 != 0
            var angles = (0..<vertexCount).map { _ in random.double(in: 0...(2 * .pi)) }
            if ordered { angles.sort() }
            var coordinates = angles.map { angle in
                let distance = radius * random.double(in: 0.3...1.0)
                return CLLocationCoordinate2D(
                    latitude: center.latitude + distance * sin(angle),
                    longitude: center.longitude + distance * cos(angle)
                )
            }
            if iteration % 2 == 0, let first = coordinates.first {
                coordinates.append(first)
            }
            let geometry = MTOfflineRegionGeometry.polygon(coordinates)
            let padding = random.optionalPadding()

            let coverage = MTTileCoverage.make(for: geometry, zoom: zoom, paddingMeters: padding)
            let reference = MTTileMath.tiles(for: geometry, zoom: zoom, paddingMeters: padding)
            #expect(coverage.tileIndices() == reference, "polygon \(coordinates) z\(zoom)")
            #expect(coverage.tileCount == reference.count)
        }
    }

    @Test("Polygon coverage matches reference when tile centers lie on edges")
    func testPolygonOnTileGrid() {
        // Vertices placed exactly on tile center coordinates exercise the strict comparisons of the point test.
        for zoom in 3...8 {
            let n = pow(2.0, Double(zoom))
            let lon = { (x: Double) in (x + 0.5) / n * 360.0 - 180.0 }
            let lat = { (y: Double) in atan(sinh(.pi * (1.0 - 2.0 * (y + 0.5) / n))) * 180.0 / .pi }
            let base = n / 2
            let geometry = MTOfflineRegionGeometry.polygon([
                CLLocationCoordinate2D(latitude: lat(base - 2), longitude: lon(base - 2)),
                CLLocationCoordinate2D(latitude: lat(base - 2), longitude: lon(base + 2)),
                CLLocationCoordinate2D(latitude: lat(base + 2), longitude: lon(base + 2)),
                CLLocationCoordinate2D(latitude: lat(base), longitude: lon(base)),
                CLLocationCoordinate2D(latitude: lat(base + 2), longitude: lon(base - 2))
            ])
            let coverage = MTTileCoverage.make(for: geometry, zoom: zoom, paddingMeters: 0)
            #expect(coverage.tileIndices() == MTTileMath.tiles(for: geometry, zoom: zoom, paddingMeters: 0))
        }
    }

    @Test("Route coverage matches reference for random routes")
    func testRandomRoutes() {
        var random = SeededRandom(seed: 3)
        for _ in 0..<300 {
            let zoom = random.int(in: 0...15)
            let step = random.double(in: 0.0005...min(10.0, 300.0 / pow(2.0, Double(zoom))))
            var current = CLLocationCoordinate2D(
                latitude: random.double(in: -70...70),
                longitude: random.double(in: -160...160)
            )
            var coordinates = [current]
            for _ in 0..<random.int(in: 0...10) {
                current = CLLocationCoordinate2D(
                    latitude: max(-80, min(80, current.latitude + random.double(in: -step...step))),
                    longitude: max(-179, min(179, current.longitude + random.double(in: -step...step)))
                )
                coordinates.append(current)
            }
            let geometry = MTOfflineRegionGeometry.route(coordinates)
            let padding = random.optionalPadding()

            let coverage = MTTileCoverage.make(for: geometry, zoom: zoom, paddingMeters: padding)
            let reference = MTTileMath.tiles(for: geometry, zoom: zoom, paddingMeters: padding)
            #expect(coverage.tileIndices() == reference, "route \(coordinates) z\(zoom)")
            #expect(coverage.tileCount == reference.count)
        }
    }

    @Test("Counts per ancestor match grouping the enumerated tiles")
    func testCountsByAncestor() {
        var random = SeededRandom(seed: 4)
        for _ in 0..<100 {
            let zoom = random.int(in: 0...13)
            let ancestorZoom = random.int(in: 0...zoom)
            let span = random.double(in: 0.01...min(30.0, 1500.0 / pow(2.0, Double(zoom))))
            let minLon = random.double(in: -180...(180 - span))
            let minLat = random.double(in: -80...(80 - span))
            let geometry: MTOfflineRegionGeometry = random.int(in: 0...1) == 0
                ? .boundingBox(MTBoundingBox(minLon: minLon, minLat: minLat, maxLon: minLon + span, maxLat: minLat + span))
                : .route([
                    CLLocationCoordinate2D(latitude: minLat, longitude: minLon),
                    CLLocationCoordinate2D(latitude: minLat + span, longitude: minLon + span / 2)
                ])
            let coverage = MTTileCoverage.make(for: geometry, zoom: zoom, paddingMeters: random.optionalPadding())

            var expected: [MTTileIndex: Int] = [:]
            let shift = zoom - ancestorZoom
            coverage.forEachTile { x, y in
                expected[MTTileIndex(x: x >> shift, y: y >> shift, z: ancestorZoom), default: 0] += 1
            }
            #expect(coverage.tileCountsByAncestor(atZoom: ancestorZoom) == expected)
        }
    }

    @Test("Counting very large regions does not enumerate tiles")
    func testLargeRegionCount() {
        let world = MTBoundingBox(minLon: -180, minLat: -85, maxLon: 180, maxLat: 85)
        let coverage = MTTileCoverage.make(for: .boundingBox(world), zoom: 22, paddingMeters: nil)
        let maxIndex = MTTileMath.safeMaxTile(for: 22)
        let bounds = MTTileMath.tileBounds(for: world, zoom: 22, buffer: 1)
        #expect(bounds.maxX == maxIndex)
        #expect(coverage.tileCount == (bounds.maxX - bounds.minX + 1) * (bounds.maxY - bounds.minY + 1))

        let switzerland = MTOfflineRegionGeometry.polygon([
            CLLocationCoordinate2D(latitude: 46.14, longitude: 6.02),
            CLLocationCoordinate2D(latitude: 45.84, longitude: 9.04),
            CLLocationCoordinate2D(latitude: 46.55, longitude: 10.47),
            CLLocationCoordinate2D(latitude: 47.8, longitude: 8.57)
        ])
        let polygonCoverage = MTTileCoverage.make(for: switzerland, zoom: 18, paddingMeters: 2000)
        #expect(polygonCoverage.tileCount > 1_000_000)
    }

    // The tiles the planner downloaded for a bounding box before coverage was introduced.
    private func referenceBoundingBoxTiles(_ bbox: MTBoundingBox, zoom: Int, paddingMeters: Double?) -> Set<MTTileIndex> {
        var tiles = Set<MTTileIndex>()
        for box in bbox.normalizedAndSplit() {
            let ranges = MTTileMath.tileRanges(for: box, zoom: zoom, paddingMeters: paddingMeters)
            for x in ranges.x {
                for y in ranges.y {
                    tiles.insert(MTTileIndex(x: x, y: y, z: zoom))
                }
            }
        }
        return tiles
    }
}

// A small deterministic random generator (SplitMix64) so failures are reproducible.
struct SeededRandom {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func double(in range: ClosedRange<Double>) -> Double {
        let unit = Double(next() >> 11) / Double(1 << 53)
        return range.lowerBound + unit * (range.upperBound - range.lowerBound)
    }

    mutating func int(in range: ClosedRange<Int>) -> Int {
        range.lowerBound + Int(next() % UInt64(range.count))
    }

    mutating func optionalPadding() -> Double? {
        switch int(in: 0...3) {
        case 0: return nil
        case 1: return 0
        default: return double(in: 1...5000)
        }
    }
}
