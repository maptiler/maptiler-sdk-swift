//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHeatmapLayerOptions.swift
//  MapTilerSDK
//

import Foundation

/// Options for building a heatmap visualization layer through the helper.
public struct MTHeatmapLayerOptions: Codable, Sendable {
    // CommonShapeLayerOptions subset
    public var data: String
    public var layerId: String?
    public var sourceId: String?
    public var beforeId: String?
    public var minzoom: Double?
    public var maxzoom: Double?

    // HeatmapLayerOptions subset
    public var property: String?
    public var weight: Double?
    public var radius: Double?
    public var opacity: Double?
    public var intensity: Double?
    public var zoomCompensation: Bool?

    public init(
        data: String,
        layerId: String? = nil,
        sourceId: String? = nil,
        beforeId: String? = nil,
        minzoom: Double? = nil,
        maxzoom: Double? = nil,
        property: String? = nil,
        weight: Double? = nil,
        radius: Double? = nil,
        opacity: Double? = nil,
        intensity: Double? = nil,
        zoomCompensation: Bool? = nil
    ) {
        self.data = data
        self.layerId = layerId
        self.sourceId = sourceId
        self.beforeId = beforeId
        self.minzoom = minzoom
        self.maxzoom = maxzoom
        self.property = property
        self.weight = weight
        self.radius = radius
        self.opacity = opacity
        self.intensity = intensity
        self.zoomCompensation = zoomCompensation
    }
}
