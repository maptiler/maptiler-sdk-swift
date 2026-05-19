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
    public let referenceStyle: MTMapReferenceStyle
    public let styleVariant: MTMapStyleVariant?
    public let bbox: MTBoundingBox
    public let minZoom: Int
    public let maxZoom: Int
    public let pixelRatio: Float

    public init(
        referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant? = nil,
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        pixelRatio: Float
    ) {
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant
        self.bbox = bbox
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.pixelRatio = pixelRatio
    }
}
