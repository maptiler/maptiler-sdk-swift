//
//  PackToolsData.swift
//  MapTilerMobileDemo
//
//  Hidden pack estimator and calibration tools. The files here are shared with the web estimator
//  (maptiler-offline-estimator), so their formats must stay in sync with it.
//

import Foundation
import MapTilerSDK

// MARK: - Locations

enum PackToolsFiles {
    static let directory: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("PackTools", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()

    static var snapshot: URL { directory.appendingPathComponent("snapshot.json") }
    static var sizeModel: URL { directory.appendingPathComponent("size-model.json") }
    static var validation: URL {
        let url = directory.appendingPathComponent("validation", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    // Where the SDK stores pack files (Caches/MapTilerSDK/Offline/<pack id>).
    static func packDirectory(for packId: String) -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MapTilerSDK/Offline", isDirectory: true)
            .appendingPathComponent(packId, isDirectory: true)
    }

    // Loads a file from Documents/PackTools, falling back to a copy bundled with the app.
    static func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        let bundled = Bundle.main.url(forResource: url.deletingPathExtension().lastPathComponent, withExtension: "json")
        for candidate in [url, bundled].compactMap({ $0 }) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let data = try? Data(contentsOf: candidate), let value = try? decoder.decode(T.self, from: data) {
                return value
            }
        }
        return nil
    }

    static func save<T: Encodable>(_ value: T, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(value).write(to: url, options: .atomic)
    }
}

// MARK: - Styles

// A built-in style and variant, identified by a stable key such as "streets/dark".
struct PackStyle: Hashable, Identifiable {
    let style: MTMapReferenceStyle
    let variant: MTMapStyleVariant

    var id: String { "\(style.getName().lowercased())/\(variant.rawValue)" }

    static let all: [PackStyle] = {
        let styles: [MTMapReferenceStyle] = [
            .streets, .outdoor, .satellite, .winter, .dataviz, .base, .bright, .topo,
            .toner, .backdrop, .openStreetMap, .aquarelle, .landscape, .ocean
        ]
        return styles.flatMap { style in
            (style.getVariants() ?? [.defaultVariant]).map { PackStyle(style: style, variant: $0) }
        }
    }()

    static func with(id: String) -> PackStyle? {
        all.first { $0.id == id }
    }
}

// MARK: - Snapshot

// Style metadata for every built-in style, resolved once so estimates need no network requests.
struct PackSnapshot: Codable {
    var version = 1
    var generatedAt: Date
    // Style key ("streets/default") to metadata, resolved with terrain enabled so it includes the terrain source.
    var styles: [String: MTOfflineStyleMetadata]
}

// MARK: - Size model

// Measured byte counts of one resource or a group of resources.
struct PackBytes: Codable, Equatable {
    // Bytes stored on disk (responses are stored decompressed).
    var bytes: Double = 0
    // Bytes transferred over the network (gzip size for compressible resources).
    var wire: Double = 0
    // Bytes allocated on disk, rounding every file up to whole file system blocks.
    var allocated: Double = 0

    static func + (lhs: PackBytes, rhs: PackBytes) -> PackBytes {
        PackBytes(bytes: lhs.bytes + rhs.bytes, wire: lhs.wire + rhs.wire, allocated: lhs.allocated + rhs.allocated)
    }

    static func += (lhs: inout PackBytes, rhs: PackBytes) {
        lhs = lhs + rhs
    }

    static func * (lhs: PackBytes, factor: Double) -> PackBytes {
        PackBytes(bytes: lhs.bytes * factor, wire: lhs.wire * factor, allocated: lhs.allocated * factor)
    }
}

// Tile sizes calibrated from sampled tiles (see maptiler-offline-estimator/calibration/calibrate.py).
//
// For zoom levels up to `groupZoom`, the size of every tile in the world is known. A deeper tile is predicted as
// the size of its ancestor at `groupZoom` times a scale factor for the ancestor's density class and the tile's zoom.
struct PackSizeModel: Codable {
    struct ExactZoom: Codable {
        // Base64 of little-endian UInt32 values, one per tile, indexed by y * 2^z + x.
        let bytes: String
        let wire: String
    }

    // Expected tile size divided by the size of its ancestor at the group zoom.
    struct Scale: Codable {
        let bytes: Double
        let wire: Double
        let allocated: Double
    }

    struct Accuracy: Codable {
        // Relative error of the summed estimate over held-out samples.
        let medianError: Double
        let p90Error: Double
        let sites: Int
    }

    struct Tileset: Codable {
        let maxCalibratedZoom: Int
        let exact: [String: ExactZoom]
        // For tilesets starting above the group zoom: the tileset whose group-zoom tiles provide the density.
        let densityTileset: String?
        // Ascending thresholds on the ancestor's byte size; the class is the number of thresholds <= size.
        let classBounds: [Double]
        // Class index (or "all") to zoom level to scale, for every zoom deeper than the group zoom up to 22.
        let scales: [String: [String: Scale]]
        // Population density bin to a correction of the scaled size (cities are denser than their zoom-4 area).
        let populationFactors: [String: Scale]?
        let accuracy: Accuracy?
    }

    // Population per tile, used as fine-grained density (see calibration/build_population.py).
    struct Population: Codable {
        // Zoom level of the population grid; tiles are grouped at this zoom when estimating.
        let zoom: Int
        // File with one little-endian UInt32 per tile at `zoom`, indexed by y * 2^zoom + x.
        let file: String
        // Ascending thresholds on population per zoom-level-sized area; the bin is the number of thresholds <= it.
        let bins: [Double]
    }

    struct PackFiles: Codable {
        // Size of the manifest, index and metadata files the SDK writes per pack.
        let fixedBytes: Double
        let bytesPerResource: Double
    }

    struct Glyphs: Codable {
        struct FontStack: Codable {
            // Size of this stack's ranges relative to the reference stack.
            let factor: Double
            // Measured ranges of this stack, keyed by first code point.
            let ranges: [String: PackBytes]
        }

        // The font stack whose ranges were all measured, keyed by first code point.
        let reference: String
        let referenceRanges: [String: PackBytes]
        // Keyed by font stack joined by commas.
        let fontStacks: [String: FontStack]
    }

    struct Overhead: Codable {
        // Keyed by style URL without query and sprite URL without query.
        let styles: [String: PackBytes]
        let sprites: [String: PackBytes]
        let glyphs: Glyphs?
    }

    let version: Int
    let generatedAt: String
    let groupZoom: Int
    let blockSize: Int
    let tilesets: [String: Tileset]
    let overhead: Overhead
    let packFiles: PackFiles?
    let population: Population?
}

// MARK: - Keys

enum PackKeys {
    // Identifies a tileset independently of host and API key, e.g. "/tiles/v4/{z}/{x}/{y}.pbf".
    static func tileset(fromTemplate template: String) -> String {
        var rest = Substring(template.split(separator: "?", maxSplits: 1).first ?? "")
        if let scheme = rest.range(of: "://") {
            rest = rest[scheme.upperBound...]
            rest = rest.firstIndex(of: "/").map { rest[$0...] } ?? ""
        }
        return String(rest)
    }

    // A URL without query parameters and host, e.g. "/maps/streets-v4/sprite".
    static func resource(fromURL url: String) -> String {
        tileset(fromTemplate: url)
    }
}
