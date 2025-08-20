//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHelpers.swift
//  MapTilerSDK
//

import Foundation
import UIKit

/// High-level convenience helpers matching the simplified JS Helpers API.
public enum MTHelpers {}

public extension MTHelpers {
    /// Options for adding a polygon fill layer via helper.
    public struct PolygonOptions: Sendable {
        public enum PolygonData: Sendable {
            case url(URL)
            case datasetUUID(String)
            case jsonString(String)
            case jsonData(Foundation.Data)
        }

        /// GeoJSON input (URL, dataset UUID, inline string or object).
        public var data: PolygonData

        /// Fill opacity (0..1). Defaults to 1.
        public var fillOpacity: Double?

        /// Fill color. Defaults to black.
        public var fillColor: UIColor?

        /// Outline color. Defaults to nil (style default).
        public var fillOutlineColor: UIColor?

        /// Enable adding an outline line layer.
        public var outline: Bool
        public var outlineWidth: Double?
        public var outlineOpacity: Double?

        /// Optional explicit identifiers to make integration predictable.
        public var sourceId: String?
        public var layerId: String?

        public init(
            data: URL,
            fillOpacity: Double? = nil,
            fillColor: UIColor? = nil,
            fillOutlineColor: UIColor? = nil,
            outline: Bool = false,
            outlineWidth: Double? = nil,
            outlineOpacity: Double? = nil,
            sourceId: String? = nil,
            layerId: String? = nil
        ) {
            self.data = .url(data)
            self.fillOpacity = fillOpacity
            self.fillColor = fillColor
            self.fillOutlineColor = fillOutlineColor
            self.outline = outline
            self.outlineWidth = outlineWidth
            self.outlineOpacity = outlineOpacity
            self.sourceId = sourceId
            self.layerId = layerId
        }

        public init(
            datasetUUID: String,
            fillOpacity: Double? = nil,
            fillColor: UIColor? = nil,
            fillOutlineColor: UIColor? = nil,
            outline: Bool = false,
            outlineWidth: Double? = nil,
            outlineOpacity: Double? = nil,
            sourceId: String? = nil,
            layerId: String? = nil
        ) {
            self.data = .datasetUUID(datasetUUID)
            self.fillOpacity = fillOpacity
            self.fillColor = fillColor
            self.fillOutlineColor = fillOutlineColor
            self.outline = outline
            self.outlineWidth = outlineWidth
            self.outlineOpacity = outlineOpacity
            self.sourceId = sourceId
            self.layerId = layerId
        }

        public init(
            geoJSONString: String,
            fillOpacity: Double? = nil,
            fillColor: UIColor? = nil,
            fillOutlineColor: UIColor? = nil,
            outline: Bool = false,
            outlineWidth: Double? = nil,
            outlineOpacity: Double? = nil,
            sourceId: String? = nil,
            layerId: String? = nil
        ) {
            self.data = .jsonString(geoJSONString)
            self.fillOpacity = fillOpacity
            self.fillColor = fillColor
            self.fillOutlineColor = fillOutlineColor
            self.outline = outline
            self.outlineWidth = outlineWidth
            self.outlineOpacity = outlineOpacity
            self.sourceId = sourceId
            self.layerId = layerId
        }

        public init(
            geoJSONObject: [String: Any],
            fillOpacity: Double? = nil,
            fillColor: UIColor? = nil,
            fillOutlineColor: UIColor? = nil,
            outline: Bool = false,
            outlineWidth: Double? = nil,
            outlineOpacity: Double? = nil,
            sourceId: String? = nil,
            layerId: String? = nil
        ) {
            let jsonData = try? JSONSerialization.data(withJSONObject: geoJSONObject, options: [])
            self.data = .jsonData(jsonData ?? Foundation.Data())
            self.fillOpacity = fillOpacity
            self.fillColor = fillColor
            self.fillOutlineColor = fillOutlineColor
            self.outline = outline
            self.outlineWidth = outlineWidth
            self.outlineOpacity = outlineOpacity
            self.sourceId = sourceId
            self.layerId = layerId
        }
    }

    /// Adds a polygon fill layer to the map from a GeoJSON URL, mirroring JS helpers.addPolygon.
    /// - Returns: An `MTPolygonLayerHelper` for future updates (optional to use).
    @MainActor
    public static func addPolygon(on mapView: MTMapView, options: PolygonOptions) async throws -> MTPolygonLayerHelper {
        var helperOptions = MTPolygonLayerHelper.Options()
        // Defaults as per JS helper: opacity 1, outline (if enabled) color white, width 1
        if let fillOpacity = options.fillOpacity { helperOptions.opacity = fillOpacity }
        if let fillColor = options.fillColor { helperOptions.fillColor = fillColor }
        if let outlineColor = options.fillOutlineColor { helperOptions.outlineColor = outlineColor }
        helperOptions.outline = options.outline
        if let w = options.outlineWidth { helperOptions.outlineWidth = w }
        if let o = options.outlineOpacity { helperOptions.outlineOpacity = o }

        let sourceId = options.sourceId ?? ("polygon-source-" + UUID().uuidString)
        let layerId = options.layerId ?? ("polygon-layer-" + UUID().uuidString)

        // Apply curated default color if none provided
        if options.fillColor == nil {
            helperOptions.fillColor = curatedColor(for: layerId)
        }

        let dataSpec: MTPolygonLayerHelper.DataSpec
        switch options.data {
        case .url(let url):
            dataSpec = .url(url)
        case .jsonString(let s):
            // Allow either full Feature/FeatureCollection or bare geometry strings
            dataSpec = .polygons([]) // temporary; replaced below with string via source init
            // We'll create the source directly below
        case .jsonData:
            dataSpec = .polygons([]) // temporary
        case .datasetUUID(let uuid):
            // Build dataset URL using API key from config
            guard let key = await MTConfig.shared.getAPIKey(),
                  let url = URL(string: "https://api.maptiler.com/data/\(uuid).geojson?key=\(key)") else {
                throw MTError.unknown(description: "Missing API key or invalid dataset URL.")
            }
            dataSpec = .url(url)
        }

        // Fast path for URL-based creation (includes dataset UUID resolved to URL above)
        if case .url = dataSpec {
            return try await MTPolygonLayerHelper.create(
                on: mapView,
                sourceId: sourceId,
                layerId: layerId,
                data: dataSpec,
                options: helperOptions
            )
        }

        // Inline JSON string/object creation
        let source: MTGeoJSONSource
        switch options.data {
        case .jsonString(let s):
            source = MTGeoJSONSource(identifier: sourceId, jsonString: s)
        case .jsonData(let data):
            let jsonStr = String(data: data, encoding: .utf8) ?? "{}"
            source = MTGeoJSONSource(identifier: sourceId, jsonString: jsonStr)
        default:
            // Should not happen due to fast path above
            throw MTError.unknown(description: "Invalid data case for inline creation")
        }

        try await mapView.style?.addSource(source)

        let layer = MTFillLayer(identifier: layerId, sourceIdentifier: sourceId)
        layer.color = helperOptions.fillColor
        layer.outlineColor = helperOptions.outlineColor
        layer.opacity = helperOptions.opacity
        layer.shouldBeAntialised = helperOptions.shouldBeAntialiased
        layer.visibility = helperOptions.visibility
        layer.minZoom = helperOptions.minZoom
        layer.maxZoom = helperOptions.maxZoom

        try await mapView.style?.addLayer(layer)

        var outlineLayer: MTLineLayer?
        if helperOptions.outline {
            let ol = MTLineLayer(identifier: layerId + "-outline", sourceIdentifier: sourceId)
            ol.color = .white
            ol.width = helperOptions.outlineWidth
            ol.opacity = helperOptions.outlineOpacity
            try await mapView.style?.addLayer(ol)
            outlineLayer = ol
        }

        return MTPolygonLayerHelper(mapView: mapView, source: source, layer: layer, outline: outlineLayer)
    }

    private static func curatedColor(for id: String) -> UIColor {
        let palette: [UIColor] = [
            UIColor(red: 0.12, green: 0.47, blue: 0.71, alpha: 1.0), // blue
            UIColor(red: 1.00, green: 0.50, blue: 0.05, alpha: 1.0), // orange
            UIColor(red: 0.17, green: 0.63, blue: 0.17, alpha: 1.0), // green
            UIColor(red: 0.84, green: 0.15, blue: 0.16, alpha: 1.0), // red
            UIColor(red: 0.58, green: 0.40, blue: 0.74, alpha: 1.0), // purple
            UIColor(red: 0.55, green: 0.34, blue: 0.29, alpha: 1.0)  // brown
        ]
        let idx = abs(id.hashValue) % palette.count
        return palette[idx]
    }
}
