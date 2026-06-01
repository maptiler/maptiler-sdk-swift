//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTGeoJSONParser.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation

/// A utility to parse GeoJSON and extract coordinates for use with offline regions or other geometry models.
public struct MTGeoJSONParser: Sendable {

    /// Extracts a flat array of coordinates from a GeoJSON payload.
    ///
    /// This is particularly useful for generating `MTOfflineRegionGeometry.route` or `.polygon`
    /// from existing GeoJSON files containing `LineString`, `Polygon`, `MultiLineString`, or `MultiPolygon` geometries.
    ///
    /// - Parameter data: The raw GeoJSON data.
    /// - Returns: An array of `CLLocationCoordinate2D` extracted from the GeoJSON.
    /// - Throws: `DecodingError` if the GeoJSON is invalid or cannot be parsed.
    public static func extractCoordinates(from data: Data) throws -> [CLLocationCoordinate2D] {
        let decoder = JSONDecoder()

        // Try decoding as a FeatureCollection
        if let featureCollection = try? decoder.decode(GeoJSONFeatureCollection.self, from: data) {
            return featureCollection.features.flatMap { extractCoordinates(from: $0.geometry) }
        }

        // Try decoding as a single Feature
        if let feature = try? decoder.decode(GeoJSONFeature.self, from: data) {
            return extractCoordinates(from: feature.geometry)
        }

        // Try decoding as a raw Geometry
        if let geometry = try? decoder.decode(GeoJSONGeometry.self, from: data) {
            return extractCoordinates(from: geometry)
        }

        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: [],
                debugDescription: "Data is not a valid GeoJSON FeatureCollection, Feature, or Geometry."
            )
        )
    }

    /// Extracts a flat array of coordinates from a GeoJSON string.
    /// - Parameter string: The GeoJSON string.
    /// - Returns: An array of `CLLocationCoordinate2D`.
    /// - Throws: An error if the string is invalid or cannot be parsed.
    public static func extractCoordinates(from string: String) throws -> [CLLocationCoordinate2D] {
        guard let data = string.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "String could not be converted to UTF-8 data."
                )
            )
        }
        return try extractCoordinates(from: data)
    }

    // MARK: - Private Internal Logic

    private static func extractCoordinates(from geometry: GeoJSONGeometry) -> [CLLocationCoordinate2D] {
        switch geometry {
        case .point(let coord):
            return [coord]
        case .lineString(let coords):
            return coords
        case .polygon(let linearRings):
            // Extract the exterior ring (the first element) and optionally interior rings
            return linearRings.flatMap { $0 }
        case .multiPoint(let coords):
            return coords
        case .multiLineString(let lines):
            return lines.flatMap { $0 }
        case .multiPolygon(let polygons):
            return polygons.flatMap { rings in rings.flatMap { $0 } }
        case .geometryCollection(let geometries):
            return geometries.flatMap { extractCoordinates(from: $0) }
        }
    }
}

// MARK: - Internal Decodable Models

private struct GeoJSONFeatureCollection: Decodable {
    let features: [GeoJSONFeature]
}

private struct GeoJSONFeature: Decodable {
    let geometry: GeoJSONGeometry
}

private enum GeoJSONGeometry: Decodable {
    case point(CLLocationCoordinate2D)
    case lineString([CLLocationCoordinate2D])
    case polygon([[CLLocationCoordinate2D]]) // Array of linear rings
    case multiPoint([CLLocationCoordinate2D])
    case multiLineString([[CLLocationCoordinate2D]])
    case multiPolygon([[[CLLocationCoordinate2D]]])
    case geometryCollection([GeoJSONGeometry])

    enum CodingKeys: String, CodingKey {
        case type
        case coordinates
        case geometries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "Point":
            let coords = try container.decode(CLLocationCoordinate2D.self, forKey: .coordinates)
            self = .point(coords)
        case "LineString":
            let coords = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
            self = .lineString(coords)
        case "Polygon":
            let coords = try container.decode([[CLLocationCoordinate2D]].self, forKey: .coordinates)
            self = .polygon(coords)
        case "MultiPoint":
            let coords = try container.decode([CLLocationCoordinate2D].self, forKey: .coordinates)
            self = .multiPoint(coords)
        case "MultiLineString":
            let coords = try container.decode([[CLLocationCoordinate2D]].self, forKey: .coordinates)
            self = .multiLineString(coords)
        case "MultiPolygon":
            let coords = try container.decode([[[CLLocationCoordinate2D]]].self, forKey: .coordinates)
            self = .multiPolygon(coords)
        case "GeometryCollection":
            let geometries = try container.decode([GeoJSONGeometry].self, forKey: .geometries)
            self = .geometryCollection(geometries)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported GeoJSON geometry type: \(type)"
            )
        }
    }
}
