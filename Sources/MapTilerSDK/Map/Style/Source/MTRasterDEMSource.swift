//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRasterDEMSource.swift
//  MapTilerSDK
//

import Foundation

/// Encoding used by the Raster DEM source.
public enum MTRasterDEMEncoding: String, Sendable {
    /// Terrarium format PNG tiles.
    case terrarium

    /// Terrain RGB tiles (Mapbox/MapTiler Terrain RGB).
    case mapbox
}

/// A raster DEM source. Only supports Terrain RGB.
public class MTRasterDEMSource: MTTileSource, @unchecked Sendable {
    /// Unique identifier of a source.
    public var identifier: String

    /// An array containing the longitude and latitude of the southwest and northeast corners
    /// of the source’s bounding box in the following order: [sw.lng, sw.lat, ne.lng, ne.lat].
    ///
    /// - Note: Defaults to [-180, -85.051129, 180, 85.051129].
    public var bounds: [Double] = [-180, -85.051129, 180, 85.051129]

    /// Maximum zoom level for which tiles are available.
    ///
    /// - Note: Defaults to 22.
    public var maxZoom: Double = 22.0

    /// Minimum zoom level for which tiles are available.
    ///
    /// - Note: Defaults to 0.
    public var minZoom: Double = 0.0

    /// The minimum visual size to display tiles for this layer. Units in pixels.
    ///
    /// - Note: Defaults to 512.
    public var tileSize: Int = 512

    /// DEM encoding format. Defaults to Terrain RGB (mapbox).
    public var encoding: MTRasterDEMEncoding = .mapbox

    /// An array of one or more tile source URLs.
    public var tiles: [URL]?

    /// A URL to a TileJSON resource. Supported protocols are http, https.
    public var url: URL?

    /// Attribution to be displayed when the map is shown to a user.
    public var attribution: String?

    /// Type of the source.
    public private(set) var type: MTSourceType = .rasterDEM

    /// Initializes the source with unique id and url to TileJSON resource.
    public init(identifier: String, url: URL) {
        self.identifier = identifier
        self.url = url
    }

    /// Initializes the source with unique id and one or more tile source urls.
    public init(identifier: String, tiles: [URL]) {
        self.identifier = identifier
        self.tiles = tiles
    }

    /// Initializes the source with all options.
    public init(
        identifier: String,
        bounds: [Double],
        maxZoom: Double,
        minZoom: Double,
        tileSize: Int = 512,
        encoding: MTRasterDEMEncoding = .mapbox,
        tiles: [URL]? = nil,
        url: URL? = nil,
        attribution: String? = nil
    ) {
        self.identifier = identifier
        self.bounds = bounds
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.tileSize = tileSize
        self.encoding = encoding
        self.tiles = tiles
        self.url = url
        self.attribution = attribution
        self.type = .rasterDEM
    }

    /// Sets the url of the source.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setURL(url: URL, in mapView: MTMapView, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapView.setURL(url: url, to: self, completionHandler: completionHandler)
    }

    /// Sets the tiles of the source.
    @MainActor
    public func setTiles(
        tiles: [URL],
        in mapView: MTMapView,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        mapView.setTiles(tiles: tiles, to: self, completionHandler: completionHandler)
    }
}

// Concurrency
extension MTRasterDEMSource {
    /// Sets the url of the source.
    @MainActor
    public func setURL(url: URL, in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            setURL(url: url, in: mapView) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the tiles of the source.
    @MainActor
    public func setTiles(tiles: [URL], in mapView: MTMapView) async {
        await withCheckedContinuation { continuation in
            setTiles(tiles: tiles, in: mapView) { _ in
                continuation.resume()
            }
        }
    }
}

// DSL
extension MTRasterDEMSource {
    /// Adds source to map DSL style.
    ///
    /// Prefer ``MTStyle/addSource(_:)`` on MTMapView instead.
    public func addToMap(_ mapView: MTMapView) {
        Task {
            let source = MTRasterDEMSource(
                identifier: self.identifier,
                bounds: self.bounds,
                maxZoom: self.maxZoom,
                minZoom: self.minZoom,
                tileSize: self.tileSize,
                encoding: self.encoding,
                tiles: self.tiles,
                url: self.url,
                attribution: self.attribution
            )

            try await mapView.style?.addSource(source)
        }
    }
}
