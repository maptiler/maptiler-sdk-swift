//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPolygonLayerHelper.swift
//  MapTilerSDK
//

import Foundation
import CoreLocation
import UIKit

/// Convenience helper for adding and managing a polygon fill layer backed by a GeoJSON source.
///
/// Composes an ``MTGeoJSONSource`` + ``MTFillLayer`` and provides a focused API for
/// adding polygons and updating them later without re-creating the whole style stack.
public final class MTPolygonLayerHelper: @unchecked Sendable {
    /// Data specification for initializing or updating the helper.
    public enum DataSpec: Sendable {
        case polygons([Polygon])
        case url(URL)
    }
    /// Geographic polygon.
    ///
    /// - Note: Coordinates are in the native iOS order (latitude, longitude) when using
    ///   ``CLLocationCoordinate2D``. Internally they are encoded to GeoJSON-compliant
    ///   [longitude, latitude] arrays.
    public struct Polygon: Sendable {
        /// Outer ring coordinates (no need to repeat the first coordinate at the end; the helper will close rings).
        public var outer: [CLLocationCoordinate2D]

        /// Optional inner rings (holes), each as an array of coordinates.
        public var holes: [[CLLocationCoordinate2D]]?

        public init(outer: [CLLocationCoordinate2D], holes: [[CLLocationCoordinate2D]]? = nil) {
            self.outer = outer
            self.holes = holes
        }
    }

    /// Visual configuration for the polygon fill layer.
    public struct Options: Sendable {
        public var fillColor: UIColor
        public var outlineColor: UIColor?
        public var opacity: Double
        public var shouldBeAntialiased: Bool
        public var visibility: MTLayerVisibility
        public var minZoom: Double?
        public var maxZoom: Double?
        // Outline controls (mirrors JS helper outline option behavior)
        public var outline: Bool
        public var outlineWidth: Double
        public var outlineOpacity: Double

        public init(
            fillColor: UIColor = .black,
            outlineColor: UIColor? = nil,
            opacity: Double = 1.0,
            shouldBeAntialiased: Bool = true,
            visibility: MTLayerVisibility = .visible,
            minZoom: Double? = nil,
            maxZoom: Double? = nil,
            outline: Bool = false,
            outlineWidth: Double = 1.0,
            outlineOpacity: Double = 1.0
        ) {
            self.fillColor = fillColor
            self.outlineColor = outlineColor
            self.opacity = opacity
            self.shouldBeAntialiased = shouldBeAntialiased
            self.visibility = visibility
            self.minZoom = minZoom
            self.maxZoom = maxZoom
            self.outline = outline
            self.outlineWidth = outlineWidth
            self.outlineOpacity = outlineOpacity
        }
    }

    private unowned let mapView: MTMapView

    /// Underlying GeoJSON source identifier.
    public let sourceId: String
    /// Underlying fill layer identifier.
    public let layerId: String

    /// Backing source reference for advanced users.
    public let source: MTGeoJSONSource
    /// Backing layer reference for advanced users.
    public let layer: MTFillLayer
    private var outline: MTLineLayer?

    /// Returns the outline layer identifier if outline is enabled.
    public var polygonOutlineLayerId: String? { outline?.identifier }

    init(mapView: MTMapView, source: MTGeoJSONSource, layer: MTFillLayer, outline: MTLineLayer? = nil) {
        self.mapView = mapView
        self.sourceId = source.identifier
        self.layerId = layer.identifier
        self.source = source
        self.layer = layer
        self.outline = outline
    }

    // MARK: - Construction

    /// Creates the GeoJSON source + fill layer and adds them to the map style.
    ///
    /// - Parameters:
    ///   - mapView: Target map view. Ensure the style is loaded (listen to MTEvent.didLoad).
    ///   - sourceId: Identifier for the source. Defaults to a generated UUID.
    ///   - layerId: Identifier for the layer. Defaults to a generated UUID.
    ///   - polygons: Polygons to render.
    ///   - options: Visual options for the fill layer.
    /// - Returns: Configured helper instance for further updates.
    @MainActor
    public static func create(
        on mapView: MTMapView,
        sourceId: String = "polygon-source-" + UUID().uuidString,
        layerId: String = "polygon-layer-" + UUID().uuidString,
        polygons: [Polygon],
        options: Options = Options()
    ) async throws -> MTPolygonLayerHelper {
        return try await create(
            on: mapView,
            sourceId: sourceId,
            layerId: layerId,
            data: .polygons(polygons),
            options: options
        )
    }

    /// Creates the GeoJSON source + fill layer using either polygon data or a URL.
    @MainActor
    public static func create(
        on mapView: MTMapView,
        sourceId: String = "polygon-source-" + UUID().uuidString,
        layerId: String = "polygon-layer-" + UUID().uuidString,
        data: DataSpec,
        options: Options = Options()
    ) async throws -> MTPolygonLayerHelper {
        let source: MTGeoJSONSource
        switch data {
        case .polygons(let polygons):
            let geoJSONString = GeoJSONBuilder.featureCollection(polygons: polygons).toJSONString()
            source = MTGeoJSONSource(identifier: sourceId, jsonString: geoJSONString)
        case .url(let url):
            source = MTGeoJSONSource(identifier: sourceId, url: url)
        }

        try await mapView.style?.addSource(source)

        let layer = MTFillLayer(identifier: layerId, sourceIdentifier: sourceId)

        // Apply options
        layer.minZoom = options.minZoom
        layer.maxZoom = options.maxZoom
        layer.color = options.fillColor
        layer.outlineColor = options.outlineColor
        layer.opacity = options.opacity
        layer.shouldBeAntialised = options.shouldBeAntialiased
        layer.visibility = options.visibility

        try await mapView.style?.addLayer(layer)

        var outlineLayer: MTLineLayer?
        if options.outline {
            let outlineId = layerId + "-outline"
            let ol = MTLineLayer(identifier: outlineId, sourceIdentifier: sourceId)
            ol.color = .white
            ol.opacity = options.outlineOpacity
            ol.width = options.outlineWidth

            try await mapView.style?.addLayer(ol)
            outlineLayer = ol
        }

        return MTPolygonLayerHelper(mapView: mapView, source: source, layer: layer, outline: outlineLayer)
    }

    /// Convenience creator for a URL-backed helper.
    @MainActor
    public static func create(
        on mapView: MTMapView,
        url: URL,
        sourceId: String = "polygon-source-" + UUID().uuidString,
        layerId: String = "polygon-layer-" + UUID().uuidString,
        options: Options = Options()
    ) async throws -> MTPolygonLayerHelper {
        try await create(on: mapView, sourceId: sourceId, layerId: layerId, data: .url(url), options: options)
    }

    // MARK: - Updates

    /// Replaces polygon geometry while preserving layer and source.
    ///
    /// Uses an inline string update to avoid removing/re-adding the source.
    @MainActor
    public func setPolygons(_ polygons: [Polygon]) async {
        let geoJSONString = GeoJSONBuilder.featureCollection(polygons: polygons).toJSONString()
        await source.setData(jsonString: geoJSONString, in: mapView)
    }

    /// Sets or switches the source to point to a remote or local GeoJSON URL.
    @MainActor
    public func setURL(_ url: URL) async {
        await mapView.setURL(url: url, to: source)
    }

    /// Unified update that accepts either polygons or a URL.
    @MainActor
    public func setData(_ data: DataSpec) async {
        switch data {
        case .polygons(let polygons):
            await setPolygons(polygons)
        case .url(let url):
            await setURL(url)
        }
    }

    /// Removes the layer and source from the style.
    @MainActor
    public func remove() async {
        guard let style = mapView.style else { return }

        do {
            try await style.removeLayer(layer)
        } catch { /* ignore if already removed */ }

        if let outline = outline {
            do {
                try await style.removeLayer(outline)
            } catch { /* ignore if already removed */ }
        }

        do {
            try await style.removeSource(source)
        } catch { /* ignore if already removed */ }
    }
}

// MARK: - GeoJSON encoding

fileprivate enum GeoJSONType: String, Codable { case FeatureCollection, Feature, Polygon }

fileprivate struct GeoJSONFeatureCollection: Codable {
    let type: GeoJSONType = .FeatureCollection
    let features: [GeoJSONFeature]
}

fileprivate struct GeoJSONFeature: Codable {
    let type: GeoJSONType = .Feature
    let geometry: GeoJSONPolygonGeometry
    let properties: [String: String]? = nil
}

fileprivate struct GeoJSONPolygonGeometry: Codable {
    let type: GeoJSONType = .Polygon
    // [[[lng, lat], ...], [hole...]]
    let coordinates: [[[Double]]]
}

fileprivate enum GeoJSONBuilder {
    static func featureCollection(polygons: [MTPolygonLayerHelper.Polygon]) -> GeoJSONFeatureCollection {
        let features = polygons.map { polygon in
            GeoJSONFeature(geometry: GeoJSONPolygonGeometry(coordinates: encodePolygon(polygon)))
        }
        return GeoJSONFeatureCollection(features: features)
    }

    private static func encodePolygon(_ polygon: MTPolygonLayerHelper.Polygon) -> [[[Double]]] {
        var rings: [[[Double]]] = []

        if !polygon.outer.isEmpty {
            rings.append(ensureClosed(polygon.outer).map { [$0.longitude, $0.latitude] })
        }

        if let holes = polygon.holes {
            for hole in holes where !hole.isEmpty {
                rings.append(ensureClosed(hole).map { [$0.longitude, $0.latitude] })
            }
        }

        return rings
    }

    private static func ensureClosed(_ ring: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard let first = ring.first, let last = ring.last else { return ring }
        if first == last { return ring }
        var closed = ring
        closed.append(first)
        return closed
    }
}

fileprivate extension GeoJSONFeatureCollection {
    func toJSONString() -> String {
        return self.toJSON() ?? ""
    }
}
