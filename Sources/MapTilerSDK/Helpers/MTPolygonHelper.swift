//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPolygonHelper.swift
//  MapTilerSDK
//

import Foundation
import UIKit

/// Data source for polygon helper.
public enum MTPolygonData {
    /// UUID of a MapTiler dataset (resolved to features.json using the configured API key).
    case datasetUUID(String)
    /// URL pointing to a GeoJSON resource.
    case url(URL)
    /// Raw GeoJSON content as String.
    case geoJSON(String)

    /// Convenience initializer from a String.
    /// If it matches UUID format, it is treated as datasetUUID; if it parses as URL it's treated as url; otherwise as raw GeoJSON string.
    public init(string: String) {
        if MTPolygonData.isUUID(string) {
            self = .datasetUUID(string)
        } else if let url = URL(string: string), url.scheme != nil {
            self = .url(url)
        } else {
            self = .geoJSON(string)
        }
    }

    private static func isUUID(_ value: String) -> Bool {
        let pattern = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}

/// Position of the polygon outline with regard to the polygon edge.
public enum MTOutlinePosition: String {
    case center
    case inside
    case outside
}

/// Options for creating a polygon layer helper.
public struct MTPolygonLayerOptions {
    // Common shape options
    public var layerId: String?
    public var sourceId: String?
    public var data: MTPolygonData
    public var minZoom: Double? = nil
    public var maxZoom: Double? = nil
    public var outline: Bool = false
    public var outlineColor: UIColor? = .white
    public var outlineWidth: Double? = 1.0
    public var outlineOpacity: Double? = 1.0

    // Polygon-specific
    public var fillColor: UIColor? = nil
    public var fillOpacity: Double? = 1.0
    public var outlinePosition: MTOutlinePosition = .center
    public var outlineDashArray: [Double]? = nil
    public var outlineDashPattern: String? = nil
    public var outlineCap: MTLineCap = .round
    public var outlineJoin: MTLineJoin = .round
    public var outlineBlur: Double? = 0.0
    public var pattern: String? = nil

    public init(
        layerId: String? = nil,
        sourceId: String? = nil,
        data: MTPolygonData,
        minZoom: Double? = nil,
        maxZoom: Double? = nil,
        outline: Bool = false,
        outlineColor: UIColor? = .white,
        outlineWidth: Double? = 1.0,
        outlineOpacity: Double? = 1.0,
        fillColor: UIColor? = nil,
        fillOpacity: Double? = 1.0,
        outlinePosition: MTOutlinePosition = .center,
        outlineDashArray: [Double]? = nil,
        outlineDashPattern: String? = nil,
        outlineCap: MTLineCap = .round,
        outlineJoin: MTLineJoin = .round,
        outlineBlur: Double? = 0.0,
        pattern: String? = nil
    ) {
        self.layerId = layerId
        self.sourceId = sourceId
        self.data = data
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.outline = outline
        self.outlineColor = outlineColor
        self.outlineWidth = outlineWidth
        self.outlineOpacity = outlineOpacity
        self.fillColor = fillColor
        self.fillOpacity = fillOpacity
        self.outlinePosition = outlinePosition
        self.outlineDashArray = outlineDashArray
        self.outlineDashPattern = outlineDashPattern
        self.outlineCap = outlineCap
        self.outlineJoin = outlineJoin
        self.outlineBlur = outlineBlur
        self.pattern = pattern
    }
}

/// Result returned from addPolygon.
public struct MTPolygonAddResult {
    public let polygonLayerId: String
    public let polygonOutlineLayerId: String?
    public let polygonSourceId: String
}

/// Helper for adding polygon layers from various data sources with styling.
public enum MTPolygonHelper {
    /// Adds a polygon with styling options to the map.
    /// - Parameters:
    ///   - mapView: Target map view.
    ///   - options: Polygon options (see MTPolygonLayerOptions).
    /// - Returns: IDs of created entities.
    @MainActor
    public static func addPolygon(
        on mapView: MTMapView,
        options: MTPolygonLayerOptions
    ) async throws -> MTPolygonAddResult {
        guard let style = mapView.style else {
            throw MTError.bridgeNotLoaded
        }

        // Resolve IDs
        let sourceId = options.sourceId ?? "maptiler-source-\(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())"
        let fillLayerId = options.layerId ?? "maptiler-layer-\(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())"

        // Build source
        let source: MTGeoJSONSource
        switch options.data {
        case .datasetUUID(let uuid):
            guard let apiKey = await MTConfig.shared.getAPIKey(), !apiKey.isEmpty else {
                throw MTError.unknown(description: "API key not set. Call MTConfig.shared.setAPIKey(_:) before using datasetUUID.")
            }
            guard let url = URL(string: "https://api.maptiler.com/data/\(uuid)/features.json?key=\(apiKey)") else {
                throw MTError.unknown(description: "Invalid dataset UUID URL")
            }
            source = MTGeoJSONSource(identifier: sourceId, url: url)
        case .url(let url):
            source = MTGeoJSONSource(identifier: sourceId, url: url)
        case .geoJSON(let json):
            source = MTGeoJSONSource(identifier: sourceId, jsonString: json)
        }

        try await style.addSource(source)

        // Fill layer
        let fill = MTFillLayer(identifier: fillLayerId, sourceIdentifier: sourceId)
        fill.minZoom = options.minZoom
        fill.maxZoom = options.maxZoom
        fill.opacity = options.fillOpacity ?? 1.0
        fill.color = options.fillColor ?? Self.randomFillColor()
        if let pattern = options.pattern { fill.pattern = pattern }

        try await style.addLayer(fill)

        // Optional outline as a line layer for better control over stroke styling
        var outlineLayerId: String? = nil
        if options.outline {
            let lineId = "\(fillLayerId)-outline"
            outlineLayerId = lineId
            let line = MTLineLayer(identifier: lineId, sourceIdentifier: sourceId)
            line.minZoom = options.minZoom
            line.maxZoom = options.maxZoom
            line.color = options.outlineColor ?? .white
            line.opacity = options.outlineOpacity ?? 1.0
            line.width = options.outlineWidth ?? 1.0
            line.blur = options.outlineBlur ?? 0.0
            line.cap = options.outlineCap
            line.join = options.outlineJoin

            // dash array (either provided directly, or parsed from pattern string)
            if let dashes = options.outlineDashArray {
                line.dashArray = dashes
            } else if let pattern = options.outlineDashPattern {
                line.dashArray = Self.parseDashPattern(pattern)
            }

            // position (center/inside/outside) using line-offset for polygon features
            let width = line.width ?? 0.0
            switch options.outlinePosition {
            case .center:
                line.offset = 0.0
            case .inside:
                line.offset = +width / 2.0
            case .outside:
                line.offset = -width / 2.0
            }

            try await style.addLayer(line)
        }

        return MTPolygonAddResult(
            polygonLayerId: fillLayerId,
            polygonOutlineLayerId: outlineLayerId,
            polygonSourceId: sourceId
        )
    }

    // MARK: - Helpers

    private static func randomFillColor() -> UIColor {
        // Curated palette similar to SDK JS helper defaults
        let hexPalette = [
            "#47A3FF", "#FF7A59", "#2ECC71", "#9B59B6", "#F1C40F",
            "#E67E22", "#1ABC9C", "#E74C3C", "#3498DB", "#8E44AD"
        ]
        let pick = hexPalette.randomElement() ?? "#3498DB"
        return UIColor(hex: pick) ?? .blue
    }

    /// Parses underscore/space pattern string into dash array, e.g. "___ _ " -> [3,1,1,1]
    private static func parseDashPattern(_ pattern: String) -> [Double] {
        var result: [Double] = []
        var count = 0
        var lastChar: Character? = nil
        for char in pattern {
            if char == "_" || char == " " {
                if lastChar == nil { lastChar = char }
                if char == lastChar { count += 1 } else {
                    if count > 0 { result.append(Double(count)) }
                    count = 1
                    lastChar = char
                }
            }
        }
        if count > 0 { result.append(Double(count)) }
        return result
    }
}

