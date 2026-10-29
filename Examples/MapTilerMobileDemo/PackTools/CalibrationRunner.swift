//
//  CalibrationRunner.swift
//  MapTilerMobileDemo
//
//  Builds the style snapshot and runs validation downloads. Tile sizes themselves are calibrated by
//  maptiler-offline-estimator/calibration/calibrate.py, which samples tiles directly and stays within a small
//  request budget. Both actions here make billed requests and can also be triggered by launch arguments:
//
//    -PackToolsBuildSnapshot YES
//    -PackToolsValidate '{"styleKey":"streets/default","bbox":[8.52,47.36,8.56,47.39],"minZoom":0,"maxZoom":14}'
//
//  Results are written to Documents/PackTools (snapshot.json, validation/<id>.json).
//

import Foundation
import MapTilerSDK

// A region to download for real and compare with its estimate.
struct ValidationRequest: Codable {
    var id: String?
    let styleKey: String
    let bbox: [Double]?
    // GeoJSON-encoded MTOfflineRegionGeometry; takes precedence over bbox.
    var geometry: String?
    let minZoom: Int
    let maxZoom: Int
    var padding: Double?
    var terrain: Bool?

    var identifier: String {
        id ?? "validation-\(styleKey.replacingOccurrences(of: "/", with: "-"))-\(minZoom)-\(maxZoom)"
    }

    var region: MTOfflineRegionDefinition? {
        guard let style = PackStyle.with(id: styleKey) else { return nil }
        let regionGeometry: MTOfflineRegionGeometry
        if let geometry, let data = geometry.data(using: .utf8),
            let decoded = try? JSONDecoder().decode(MTOfflineRegionGeometry.self, from: data) {
            regionGeometry = decoded
        } else if let bbox, bbox.count == 4 {
            regionGeometry = .boundingBox(
                MTBoundingBox(minLon: bbox[0], minLat: bbox[1], maxLon: bbox[2], maxLat: bbox[3])
            )
        } else {
            return nil
        }
        return MTOfflineRegionDefinition(
            geometry: regionGeometry,
            minZoom: minZoom,
            maxZoom: maxZoom,
            referenceStyle: style.style,
            styleVariant: style.variant,
            padding: padding,
            isTerrainEnabled: terrain ?? false
        )
    }
}

// The outcome of a validation download: what was estimated and what was measured.
struct ValidationResult: Codable {
    struct Estimate: Codable {
        let resourceCount: Int
        let tileCount: Int
        let size: PackBytes?
        let sizeLow: PackBytes?
        let sizeHigh: PackBytes?
    }

    let request: ValidationRequest
    let date: Date
    let estimate: Estimate
    let measurement: PackMeasurement
}

@MainActor
final class CalibrationRunner: ObservableObject {
    @Published private(set) var snapshot: PackSnapshot? = PackToolsFiles.load(
        PackSnapshot.self,
        from: PackToolsFiles.snapshot
    )
    @Published private(set) var isRunning = false
    @Published private(set) var currentProgress: Double = 0
    @Published private(set) var log: [String] = []

    // Runs the actions requested by launch arguments, once the API key is set.
    static func runLaunchActions() async {
        // Read raw arguments: UserDefaults would parse a JSON object value as a property list.
        let arguments = ProcessInfo.processInfo.arguments
        func value(for name: String) -> String? {
            arguments.firstIndex(of: "-\(name)").flatMap { $0 + 1 < arguments.count ? arguments[$0 + 1] : nil }
        }

        let runner = CalibrationRunner()
        if value(for: "PackToolsBuildSnapshot") == "YES" {
            await runner.buildSnapshot()
        }
        if let json = value(for: "PackToolsEstimate"),
            let request = try? JSONDecoder().decode(ValidationRequest.self, from: Data(json.utf8)) {
            runner.estimateOnly(request)
        }
        if let json = value(for: "PackToolsValidate"),
            let request = try? JSONDecoder().decode(ValidationRequest.self, from: Data(json.utf8)) {
            _ = await runner.validate(request)
        }
        for line in runner.log {
            print("[PackTools] \(line)")
        }
    }

    // MARK: Snapshot

    // Resolves the metadata of every built-in style. Costs a few requests per style (style JSON and TileJSONs).
    func buildSnapshot() async {
        isRunning = true
        defer { isRunning = false }

        var styles: [String: MTOfflineStyleMetadata] = [:]
        let estimator = MTOfflineEstimator()
        for style in PackStyle.all {
            let region = MTOfflineRegionDefinition(
                bbox: MTBoundingBox(minLon: 8.5, minLat: 47.3, maxLon: 8.6, maxLat: 47.4),
                minZoom: 0,
                maxZoom: 1,
                referenceStyle: style.style,
                styleVariant: style.variant,
                isTerrainEnabled: true
            )
            do {
                styles[style.id] = try await estimator.styleMetadata(for: region)
                append("Resolved \(style.id)")
            } catch {
                append("Failed to resolve \(style.id): \(error)")
            }
        }

        let snapshot = PackSnapshot(generatedAt: Date(), styles: styles)
        do {
            try PackToolsFiles.save(snapshot, to: PackToolsFiles.snapshot)
            self.snapshot = snapshot
            append("Snapshot saved with \(styles.count) styles")
        } catch {
            append("Failed to save snapshot: \(error)")
        }
    }

    // MARK: Validation

    // Writes the estimate of a region to validation/<id>-estimate.json without any network requests.
    func estimateOnly(_ request: ValidationRequest) {
        guard let region = request.region, let metadata = snapshot?.styles[request.styleKey],
            let model = PackToolsFiles.load(PackSizeModel.self, from: PackToolsFiles.sizeModel) else {
            append("Estimate needs a snapshot, a size model and a valid region")
            return
        }
        do {
            let stats = try MTOfflineEstimator().estimatePack(region: region, styleMetadata: metadata)
            let size = try PackSizeEstimator.estimate(region: region, metadata: metadata, stats: stats, model: model)
            let result: [String: Double] = [
                "resourceCount": Double(stats.resourceCount),
                "tileCount": Double(stats.tileCount),
                "tilesBytes": size.tiles.bytes,
                "tilesAllocated": size.tiles.allocated,
                "overheadAllocated": size.overhead.allocated,
                "totalAllocated": size.total.allocated,
                "tileError": size.tileError
            ]
            let fileURL = PackToolsFiles.validation.appendingPathComponent("\(request.identifier)-estimate.json")
            try PackToolsFiles.save(result, to: fileURL)
            append("Estimated \(request.identifier)")
        } catch {
            append("Estimate failed: \(error)")
        }
    }

    // Estimates a region, downloads it through the SDK, measures the files and deletes the pack.
    // swiftlint:disable:next function_body_length
    func validate(_ request: ValidationRequest) async -> ValidationResult? {
        guard !isRunning else { return nil }
        isRunning = true
        currentProgress = 0
        defer { isRunning = false }

        guard let region = request.region, let metadata = snapshot?.styles[request.styleKey] else {
            append("Validation needs a snapshot and a valid region")
            return nil
        }

        do {
            let stats = try MTOfflineEstimator().estimatePack(region: region, styleMetadata: metadata)
            let model = PackToolsFiles.load(PackSizeModel.self, from: PackToolsFiles.sizeModel)
            let size = try model.map {
                try PackSizeEstimator.estimate(region: region, metadata: metadata, stats: stats, model: $0)
            }
            append("Downloading \(request.identifier) (\(stats.resourceCount) requests)")

            let pack = try await MTOfflinePack.createPack(region: region)
            let started = Date()
            let progressTask = Task { [weak self] in
                while !Task.isCancelled {
                    let progress = await pack.progress
                    self?.currentProgress = Double(progress.percentage)
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
            }
            do {
                try await pack.download()
            } catch {
                append("Download error: \(error)")
            }
            progressTask.cancel()

            let measurement = try PackMeasurer.measure(
                packId: pack.id,
                jobId: request.identifier,
                region: region,
                metadata: metadata,
                state: await pack.state.rawValue,
                seconds: Date().timeIntervalSince(started)
            )
            try? await pack.remove()

            let result = ValidationResult(
                request: request,
                date: Date(),
                estimate: .init(
                    resourceCount: stats.resourceCount,
                    tileCount: stats.tileCount,
                    size: size?.total,
                    sizeLow: size.map { estimate in
                        PackBytes(
                            bytes: estimate.range(\.bytes).low,
                            wire: estimate.range(\.wire).low,
                            allocated: estimate.range(\.allocated).low
                        )
                    },
                    sizeHigh: size.map { estimate in
                        PackBytes(
                            bytes: estimate.range(\.bytes).high,
                            wire: estimate.range(\.wire).high,
                            allocated: estimate.range(\.allocated).high
                        )
                    }
                ),
                measurement: measurement
            )
            let resultURL = PackToolsFiles.validation.appendingPathComponent("\(request.identifier).json")
            try PackToolsFiles.save(result, to: resultURL)
            append("\(request.identifier): \(measurement.state), \(measurement.fileCount) tile files")
            return result
        } catch {
            append("Validation failed: \(error)")
            return nil
        }
    }

    private func append(_ message: String) {
        log.append(message)
        if log.count > 200 { log.removeFirst(log.count - 200) }
    }
}

// MARK: - Measuring

// The files a pack wrote to disk, as stored in Documents/PackTools/measurements.
struct PackMeasurement: Codable {
    struct Tile: Codable {
        let z: Int
        let x: Int
        let y: Int
        let bytes: Int
        let wire: Int
        let allocated: Int
    }

    let jobId: String
    let state: String
    let seconds: Double
    let resourceCount: Int
    // Source id to tileset key.
    let sources: [String: String]
    // Tileset key to the tiles that were written (tiles without content are not stored).
    let tiles: [String: [Tile]]
    // Tileset key to zoom level to the number of planned tiles.
    let plannedTiles: [String: [String: Int]]
    let style: PackBytes
    let styleKeyURL: String?
    // Sprite URL key to bytes.
    let sprites: [String: PackBytes]
    // Font stack to bytes of all its ranges.
    let fontStacks: [String: PackBytes]
    // Manifest, index and metadata files.
    let packFiles: PackBytes

    var fileCount: Int { tiles.values.reduce(0) { $0 + $1.count } }

    var total: PackBytes {
        let tileBytes = tiles.values.joined().reduce(PackBytes()) {
            $0 + PackBytes(bytes: Double($1.bytes), wire: Double($1.wire), allocated: Double($1.allocated))
        }
        return [style, packFiles].reduce(tileBytes, +)
            + sprites.values.reduce(PackBytes(), +)
            + fontStacks.values.reduce(PackBytes(), +)
    }
}

enum PackMeasurer {
    // swiftlint:disable:next function_body_length function_parameter_count
    static func measure(
        packId: String,
        jobId: String,
        region: MTOfflineRegionDefinition,
        metadata: MTOfflineStyleMetadata,
        state: String,
        seconds: Double
    ) throws -> PackMeasurement {
        let directory = PackToolsFiles.packDirectory(for: packId)
        let allSources = metadata.sources + [metadata.terrainSource].compactMap { $0 }
        let tilesetBySource = Dictionary(
            allSources.map { ($0.id, PackKeys.tileset(fromTemplate: $0.tileURLTemplate)) }
        ) { first, _ in first }
        let spriteKeyById = Dictionary(
            metadata.sprites.map { ($0.id, PackKeys.resource(fromURL: $0.url)) }
        ) { first, _ in first }

        var tiles: [String: [PackMeasurement.Tile]] = [:]
        var sprites: [String: PackBytes] = [:]
        var fontStacks: [String: PackBytes] = [:]
        var style = PackBytes()
        var packFiles = PackBytes()

        let keys: [URLResourceKey] = [.fileSizeKey, .totalFileAllocatedSizeKey, .isRegularFileKey]
        let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: keys)
        while let url = enumerator?.nextObject() as? URL {
            let values = try url.resourceValues(forKeys: Set(keys))
            guard values.isRegularFile == true else { continue }
            let bytes = values.fileSize ?? 0
            let allocated = values.totalFileAllocatedSize ?? bytes
            let relative = Array(url.pathComponents.dropFirst(directory.pathComponents.count))
            // MapTiler serves tiles and glyphs without transfer compression,
            // so the transferred size is the stored size.
            let wire = bytes
            let measured = PackBytes(bytes: Double(bytes), wire: Double(wire), allocated: Double(allocated))

            switch relative.first {
            case "tiles" where relative.count == 5:
                guard let tileset = tilesetBySource[relative[1]],
                    let z = Int(relative[2]),
                    let x = Int(relative[3]),
                    let y = Int(relative[4].split(separator: ".").first ?? "") else { continue }
                tiles[tileset, default: []].append(
                    .init(z: z, x: x, y: y, bytes: bytes, wire: wire, allocated: allocated)
                )
            case "glyphs" where relative.count == 3:
                fontStacks[relative[1], default: PackBytes()] += measured
            case "style.json":
                style = measured
            case let name? where name.hasPrefix("sprite"):
                // sprite.json, sprite@2x.png, sprite-<id>.json, sprite-<id>@2x.png
                let stem = name.split(separator: ".").first.map(String.init) ?? name
                let base = stem.replacingOccurrences(of: "@2x", with: "")
                let id = base == "sprite" ? "default" : String(base.dropFirst("sprite-".count))
                let key = spriteKeyById[id] ?? id
                sprites[key, default: PackBytes()] += measured
            default:
                packFiles += measured
            }
        }

        var plannedTiles: [String: [String: Int]] = [:]
        var resourceCount = 0
        if let stats = try? MTOfflineEstimator().estimatePack(region: region, styleMetadata: metadata) {
            resourceCount = stats.resourceCount
            for source in stats.sources {
                guard let tileset = tilesetBySource[source.id] else { continue }
                for (zoom, count) in source.tilesPerZoom {
                    plannedTiles[tileset, default: [:]][String(zoom), default: 0] += count
                }
            }
        }

        return PackMeasurement(
            jobId: jobId,
            state: state,
            seconds: seconds,
            resourceCount: resourceCount,
            sources: tilesetBySource,
            tiles: tiles,
            plannedTiles: plannedTiles,
            style: style,
            styleKeyURL: metadata.styleURL.map(PackKeys.resource(fromURL:)),
            sprites: sprites,
            fontStacks: fontStacks,
            packFiles: packFiles
        )
    }
}
