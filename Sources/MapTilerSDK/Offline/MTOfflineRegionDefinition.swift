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
    public let minZoom: Int
    /// The maximum zoom level.
    public let maxZoom: Int
    /// The reference style for the map.
    public let referenceStyle: MTMapReferenceStyle
    /// The optional style variant.
    public let styleVariant: MTMapStyleVariant?
    /// The device pixel ratio.
    public let pixelRatio: Float
    /// The maximum number of tiles allowed for this region.
    public let maxTileCount: Int?

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
        maxTileCount: Int? = nil
    ) {
        self.geometry = geometry
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant
        self.pixelRatio = pixelRatio
        self.maxTileCount = maxTileCount
    }

    public init(
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant? = nil,
        pixelRatio: Float = 1.0,
        maxTileCount: Int? = nil
    ) {
        self.init(
            geometry: .boundingBox(bbox),
            minZoom: minZoom,
            maxZoom: maxZoom,
            referenceStyle: referenceStyle,
            styleVariant: styleVariant,
            pixelRatio: pixelRatio,
            maxTileCount: maxTileCount
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
    }
}
