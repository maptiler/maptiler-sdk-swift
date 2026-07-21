//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineRegionDefinition.swift
//  MapTilerSDK
//

import Foundation

/// Defines a region for offline download.
public struct MTOfflineRegionDefinition: Codable, Equatable, Sendable {
    /// The geometry of the region.
    public let geometry: MTOfflineRegionGeometry

    /// The minimum zoom level.
    ///
    /// - Note: This defines the data fetched from the server, *not* the camera's zoom limit.
    /// If you download a very small geographic area (e.g., a single neighborhood) and set `minZoom` to 0, 
    /// the map camera may still prevent the user from zooming out to 0 when loading the pack. 
    /// This is because the camera is physically constrained by the bounding box of the downloaded data 
    /// to prevent the user from panning into "blank" map areas. 
    /// The apparent minimum zoom is dictated by the screen size 
    /// relative to the bounding box.
    public let minZoom: Int

    /// The maximum zoom level.
    ///
    /// Higher zoom levels provide street-level detail but exponentially increase the storage size.
    ///
    /// - Note: If you request a `maxZoom` that exceeds the source's maximum available zoom 
    /// (e.g., requesting zoom 18 for MapTiler Planet vector tiles which end at zoom 14), the SDK 
    /// will automatically download the highest available resolution (zoom 14) for that area. 
    /// This ensures that the map engine can perform client-side "overzooming" to render 
    /// the requested detail level offline.
    public let maxZoom: Int
    /// The reference style for the map.
    public let referenceStyle: MTMapReferenceStyle
    /// The optional style variant.
    public let styleVariant: MTMapStyleVariant?
    /// The device pixel ratio.
    public let pixelRatio: Float
    /// The maximum number of tiles allowed for this region.
    public let maxTileCount: Int?
    /// An optional buffer in meters to add around the geometry for map interaction and tile fetching. 
    /// If not explicitly provided, a default heuristic buffer (~2000m) may be applied 
    /// for flexible geometries (routes and polygons).
    public let padding: Double?
    /// Boolean indicating whether 3D terrain is enabled for this offline region.
    public let isTerrainEnabled: Bool

    /// The bounding box of the region.
    public var bbox: MTBoundingBox {
        geometry.bbox
    }

    public init(
        geometry: MTOfflineRegionGeometry,
        minZoom: Int,
        maxZoom: Int,
        referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant? = nil,
        pixelRatio: Float = 1.0,
        maxTileCount: Int? = nil,
        padding: Double? = nil,
        isTerrainEnabled: Bool = false
    ) {
        self.geometry = geometry
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant
        self.pixelRatio = pixelRatio
        self.maxTileCount = maxTileCount
        self.padding = padding
        self.isTerrainEnabled = isTerrainEnabled
    }

    public init(
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant? = nil,
        pixelRatio: Float = 1.0,
        maxTileCount: Int? = nil,
        padding: Double? = nil,
        isTerrainEnabled: Bool = false
    ) {
        self.init(
            geometry: .boundingBox(bbox),
            minZoom: minZoom,
            maxZoom: maxZoom,
            referenceStyle: referenceStyle,
            styleVariant: styleVariant,
            pixelRatio: pixelRatio,
            maxTileCount: maxTileCount,
            padding: padding,
            isTerrainEnabled: isTerrainEnabled
        )
    }

    enum CodingKeys: String, CodingKey {
        case geometry
        case bbox
        case minZoom
        case maxZoom
        case referenceStyle
        case styleVariant
        case pixelRatio
        case maxTileCount
        case padding
        case isTerrainEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let geometry = try? container.decode(MTOfflineRegionGeometry.self, forKey: .geometry) {
            self.geometry = geometry
        } else if let bbox = try? container.decode(MTBoundingBox.self, forKey: .bbox) {
            self.geometry = .boundingBox(bbox)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .geometry,
                in: container,
                debugDescription: "MTOfflineRegionDefinition must have either 'geometry' or 'bbox'"
            )
        }

        self.minZoom = try container.decode(Int.self, forKey: .minZoom)
        self.maxZoom = try container.decode(Int.self, forKey: .maxZoom)
        self.referenceStyle = try container.decode(MTMapReferenceStyle.self, forKey: .referenceStyle)
        self.styleVariant = try container.decodeIfPresent(MTMapStyleVariant.self, forKey: .styleVariant)
        self.pixelRatio = try container.decode(Float.self, forKey: .pixelRatio)
        self.maxTileCount = try container.decodeIfPresent(Int.self, forKey: .maxTileCount)
        self.padding = try container.decodeIfPresent(Double.self, forKey: .padding)
        self.isTerrainEnabled = try container.decodeIfPresent(Bool.self, forKey: .isTerrainEnabled) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(geometry, forKey: .geometry)
        try container.encode(bbox, forKey: .bbox)
        try container.encode(minZoom, forKey: .minZoom)
        try container.encode(maxZoom, forKey: .maxZoom)
        try container.encode(referenceStyle, forKey: .referenceStyle)
        try container.encodeIfPresent(styleVariant, forKey: .styleVariant)
        try container.encode(pixelRatio, forKey: .pixelRatio)
        try container.encodeIfPresent(maxTileCount, forKey: .maxTileCount)
        try container.encodeIfPresent(padding, forKey: .padding)
        try container.encode(isTerrainEnabled, forKey: .isTerrainEnabled)
    }
}
