//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTManifestMetadata.swift
//  MapTilerSDK
//

import Foundation

// Metadata storing the original request parameters for the manifest.
internal struct MTManifestMetadata: Codable, Sendable {
    public let mapId: String?
    public let styleURL: URL?
    public let bbox: MTBoundingBox
    public let minZoom: Int
    public let maxZoom: Int
    public let pixelRatio: Float

    public init(
        mapId: String? = nil,
        styleURL: URL? = nil,
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        pixelRatio: Float
    ) {
        self.mapId = mapId
        self.styleURL = styleURL
        self.bbox = bbox
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.pixelRatio = pixelRatio
    }
}
