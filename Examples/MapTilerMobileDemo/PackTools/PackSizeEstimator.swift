//
//  PackSizeEstimator.swift
//  MapTilerMobileDemo
//
//  Predicts pack sizes from the calibrated size model. The web estimator implements the same algorithm.
//

import Foundation
@_spi(PackTools) import MapTilerSDK

// Estimated bytes with lower and upper bound.
struct SizeRange {
    let low: Double
    let value: Double
    let high: Double
}

struct PackSizeEstimate {
    // Predicted bytes of the tiles.
    var tiles = PackBytes()
    // Bytes of the style, sprites and glyphs.
    var overhead = PackBytes()
    // Manifest, index and metadata files the SDK writes next to the resources.
    var packFiles = PackBytes()
    // Relative error (90th percentile from calibration), weighted by tile bytes.
    var tileError: Double = 0
    // Sources without calibration data; their tiles use rough average sizes.
    var uncalibratedSources: [String] = []
    // Sources requested deeper than calibrated; their deepest zoom levels are extrapolated.
    var extrapolatedSources: [String] = []
    // Style resources without measurements; they use rough average sizes.
    var unmeasuredOverhead: [String] = []

    var total: PackBytes { tiles + overhead + packFiles }

    // Total bytes, lower and upper bound, for one channel.
    func range(_ channel: KeyPath<PackBytes, Double>) -> SizeRange {
        let value = total[keyPath: channel]
        let margin = tiles[keyPath: channel] * tileError
        return SizeRange(low: max(0, value - margin), value: value, high: value + margin)
    }

    var isRough: Bool {
        !uncalibratedSources.isEmpty || !unmeasuredOverhead.isEmpty
    }
}

enum PackSizeEstimator {
    // Rough fallbacks matching the SDK's averages, used only where the model has no data.
    private static let fallbackVectorTile = 25_000.0
    private static let fallbackRasterTile = 150_000.0
    private static let fallbackStyle = 100_000.0
    private static let fallbackSpriteFile = 50_000.0
    private static let fallbackGlyphRange = 15_000.0

    static func estimate(
        region: MTOfflineRegionDefinition,
        metadata: MTOfflineStyleMetadata,
        stats: MTPackStats,
        model: PackSizeModel
    ) throws -> PackSizeEstimate {
        var estimate = PackSizeEstimate()
        let decoder = ExactSizeDecoder(model: model)
        let groupZoom = model.groupZoom
        let block = Double(model.blockSize)
        let population = model.population.flatMap(PopulationGrid.load)

        let sources = Dictionary(
            (metadata.sources + [metadata.terrainSource].compactMap { $0 }).map { ($0.id, $0) }
        ) { first, _ in first }

        var errorWeighted = 0.0
        // With population data, tiles are grouped finer so each group has its own density.
        let groups = try MTOfflineEstimator().tileGroups(
            region: region,
            styleMetadata: metadata,
            groupZoom: max(groupZoom, population?.zoom ?? groupZoom)
        )

        for group in groups {
            guard let source = sources[group.sourceId] else { continue }
            let key = PackKeys.tileset(fromTemplate: source.tileURLTemplate)

            guard let tileset = model.tilesets[key] else {
                let isRaster = source.type == .raster || source.type == .rasterDEM
                let size = Double(group.tileCount) * (isRaster ? fallbackRasterTile : fallbackVectorTile)
                estimate.tiles += PackBytes(bytes: size, wire: size, allocated: size)
                append(source.id, to: &estimate.uncalibratedSources)
                continue
            }

            // The ancestor at the model's group zoom, whose size the prediction scales.
            let ancestorZoom = min(group.ancestorZoom, groupZoom)
            let shift = group.ancestorZoom - ancestorZoom
            let ancestor = decoder.size(
                tileset: tileset.densityTileset ?? key,
                zoom: ancestorZoom,
                x: group.ancestorX >> shift,
                y: group.ancestorY >> shift
            )
            var predicted: PackBytes

            if group.zoom <= groupZoom {
                predicted = PackBytes(
                    bytes: ancestor.bytes,
                    wire: ancestor.wire,
                    allocated: (ancestor.bytes / block).rounded(.up) * block
                )
            } else {
                let densityClass = tileset.classBounds.filter { $0 <= ancestor.bytes }.count
                let scale = scale(in: tileset, densityClass: densityClass, zoom: group.zoom)
                var factor = PackSizeModel.Scale(bytes: 1, wire: 1, allocated: 1)
                if let population, let factors = tileset.populationFactors, let bins = model.population?.bins {
                    let density = population.density(zoom: group.ancestorZoom, x: group.ancestorX, y: group.ancestorY)
                    factor = factors[String(bins.filter { $0 <= density }.count)] ?? factor
                }
                predicted = PackBytes(
                    bytes: ancestor.bytes * scale.bytes * factor.bytes,
                    wire: ancestor.wire * scale.wire * factor.wire,
                    allocated: (ancestor.bytes / block).rounded(.up) * block * scale.allocated * factor.allocated
                ) * Double(group.tileCount)

                if group.zoom > tileset.maxCalibratedZoom {
                    append(source.id, to: &estimate.extrapolatedSources)
                }
            }

            estimate.tiles += predicted
            errorWeighted += predicted.bytes * (tileset.accuracy?.p90Error ?? 1)
        }
        estimate.tileError = estimate.tiles.bytes > 0 ? errorWeighted / estimate.tiles.bytes : 0

        addOverhead(metadata: metadata, glyphRanges: region.glyphRanges, model: model, to: &estimate)

        if let packFiles = model.packFiles {
            let bytes = packFiles.fixedBytes + packFiles.bytesPerResource * Double(stats.resourceCount)
            estimate.packFiles = PackBytes(bytes: bytes, wire: 0, allocated: (bytes / block).rounded(.up) * block)
        }
        return estimate
    }

    // The scale for a zoom level: the density class's own, else the pooled one.
    private static func scale(in tileset: PackSizeModel.Tileset, densityClass: Int, zoom: Int) -> PackSizeModel.Scale {
        let level = String(zoom)
        return tileset.scales[String(densityClass)]?[level]
            ?? tileset.scales["all"]?[level]
            ?? PackSizeModel.Scale(bytes: 0, wire: 0, allocated: 0)
    }

    private static func addOverhead(
        metadata: MTOfflineStyleMetadata,
        glyphRanges: MTOfflineGlyphRanges,
        model: PackSizeModel,
        to estimate: inout PackSizeEstimate
    ) {
        if let styleURL = metadata.styleURL {
            if let measured = model.overhead.styles[PackKeys.resource(fromURL: styleURL)] {
                estimate.overhead += measured
            } else {
                estimate.overhead += rough(fallbackStyle)
                estimate.unmeasuredOverhead.append("style")
            }
        }

        for sprite in metadata.sprites {
            if let measured = model.overhead.sprites[PackKeys.resource(fromURL: sprite.url)] {
                estimate.overhead += measured
            } else {
                estimate.overhead += rough(fallbackSpriteFile * 4)
                estimate.unmeasuredOverhead.append("sprite \(sprite.id)")
            }
        }

        guard metadata.glyphsTemplate != nil else { return }
        let starts = glyphRanges.rangeStarts.map(String.init)
        for fontStack in metadata.fontStacks {
            let key = fontStack.joined(separator: ",")
            guard let glyphs = model.overhead.glyphs, let stack = glyphs.fontStacks[key] else {
                estimate.overhead += rough(fallbackGlyphRange * Double(starts.count))
                estimate.unmeasuredOverhead.append("glyphs \(key)")
                continue
            }
            for start in starts {
                let measured = stack.ranges[start] ?? glyphs.referenceRanges[start].map { $0 * stack.factor }
                estimate.overhead += measured ?? rough(fallbackGlyphRange)
            }
        }
    }

    private static func rough(_ bytes: Double) -> PackBytes {
        PackBytes(bytes: bytes, wire: bytes, allocated: bytes)
    }

    private static func append(_ value: String, to list: inout [String]) {
        if !list.contains(value) { list.append(value) }
    }
}

// Decodes and caches the per-tile sizes stored in the model.
private final class ExactSizeDecoder {
    private let model: PackSizeModel
    private var cache: [String: (bytes: [UInt32], wire: [UInt32])] = [:]

    init(model: PackSizeModel) {
        self.model = model
    }

    func size(tileset: String, zoom: Int, x: Int, y: Int) -> (bytes: Double, wire: Double) {
        let cacheKey = "\(tileset)|\(zoom)"
        if cache[cacheKey] == nil, let exact = model.tilesets[tileset]?.exact[String(zoom)] {
            cache[cacheKey] = (decode(exact.bytes), decode(exact.wire))
        }
        guard let values = cache[cacheKey] else { return (0, 0) }
        let index = y * (1 << zoom) + x
        guard index >= 0, index < values.bytes.count, index < values.wire.count else { return (0, 0) }
        return (Double(values.bytes[index]), Double(values.wire[index]))
    }

    private func decode(_ base64: String) -> [UInt32] {
        guard let data = Data(base64Encoded: base64) else { return [] }
        return data.withUnsafeBytes { raw in
            (0..<(data.count / 4)).map {
                UInt32(littleEndian: raw.loadUnaligned(fromByteOffset: $0 * 4, as: UInt32.self))
            }
        }
    }
}

// Population per tile at the grid's zoom, with on-demand sums for coarser tiles.
private final class PopulationGrid {
    let zoom: Int
    private let values: [UInt32]
    private var sums: [String: Double] = [:]

    private init(zoom: Int, values: [UInt32]) {
        self.zoom = zoom
        self.values = values
    }

    static func load(_ population: PackSizeModel.Population) -> PopulationGrid? {
        let url = PackToolsFiles.directory.appendingPathComponent(population.file)
        let bundled = Bundle.main.url(forResource: population.file, withExtension: nil)
        guard let data = (try? Data(contentsOf: url)) ?? bundled.flatMap({ try? Data(contentsOf: $0) }),
            data.count == 4 << (2 * population.zoom) else { return nil }
        let values = data.withUnsafeBytes { raw in
            (0..<(data.count / 4)).map {
                UInt32(littleEndian: raw.loadUnaligned(fromByteOffset: $0 * 4, as: UInt32.self))
            }
        }
        return PopulationGrid(zoom: population.zoom, values: values)
    }

    // Population of a tile at `zoom` (not deeper than the grid), scaled to the area of a grid tile.
    func density(zoom tileZoom: Int, x: Int, y: Int) -> Double {
        let shift = zoom - tileZoom
        let key = "\(tileZoom)/\(x)/\(y)"
        if let cached = sums[key] { return cached }
        let size = 1 << shift
        let width = 1 << zoom
        var total = 0.0
        for row in (y << shift)..<((y << shift) + size) {
            for column in (x << shift)..<((x << shift) + size) {
                total += Double(values[row * width + column])
            }
        }
        let density = total / pow(4.0, Double(shift))
        sums[key] = density
        return density
    }
}
