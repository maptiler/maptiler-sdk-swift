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
    /// The bounding box of the region.
    public let bbox: MTBoundingBox
    /// The minimum zoom level.
    public let minZoom: Int
    /// The maximum zoom level.
    public let maxZoom: Int
    /// The map ID.
    public let mapId: String?
    /// The style URL for the region.
    public let styleURL: URL?
    /// The device pixel ratio.
    public let pixelRatio: Float
    /// The maximum number of tiles allowed for this region.
    public let maxTileCount: Int?

    public init(
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        mapId: String? = nil,
        styleURL: URL? = nil,
        pixelRatio: Float = 1.0,
        maxTileCount: Int? = nil
    ) {
        self.bbox = bbox
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.mapId = mapId
        self.styleURL = styleURL
        self.pixelRatio = pixelRatio
        self.maxTileCount = maxTileCount
    }
}
