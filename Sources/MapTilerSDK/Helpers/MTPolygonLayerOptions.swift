//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPolygonLayerOptions.swift
//  MapTilerSDK
//

import Foundation

/// Options for building a polygon (fill) visualization layer through the helper.
public struct MTPolygonLayerOptions: Codable, Sendable {
    // CommonShapeLayerOptions
    public var data: String
    public var layerId: String?
    public var sourceId: String?
    public var beforeId: String?
    public var minzoom: Double?
    public var maxzoom: Double?
    public var outline: Bool?
    public var outlineColor: MTStringOrZoomStringValues?
    public var outlineWidth: MTNumberOrZoomNumberValues?
    public var outlineOpacity: MTNumberOrZoomNumberValues?

    // Polygon-specific options
    public var fillColor: MTStringOrZoomStringValues?
    public var fillOpacity: MTNumberOrZoomNumberValues?
    public var outlinePosition: String? // "center" | "inside" | "outside"
    public var outlineDashArray: MTDashArrayValue?
    public var outlineCap: String? // "butt" | "round" | "square"
    public var outlineJoin: String? // "bevel" | "round" | "miter"
    public var pattern: String?
    public var outlineBlur: MTNumberOrZoomNumberValues?

    public init(
        data: String,
        layerId: String? = nil,
        sourceId: String? = nil,
        beforeId: String? = nil,
        minzoom: Double? = nil,
        maxzoom: Double? = nil,
        outline: Bool? = nil,
        outlineColor: String? = nil,
        outlineWidth: Double? = nil,
        outlineOpacity: Double? = nil,
        fillColor: String? = nil,
        fillOpacity: Double? = nil,
        outlinePosition: String? = nil,
        outlineDashArray: String? = nil,
        outlineCap: String? = nil,
        outlineJoin: String? = nil,
        pattern: String? = nil,
        outlineBlur: Double? = nil
    ) {
        self.data = data
        self.layerId = layerId
        self.sourceId = sourceId
        self.beforeId = beforeId
        self.minzoom = minzoom
        self.maxzoom = maxzoom
        self.outline = outline
        self.outlineColor = outlineColor.map { .string($0) }
        self.outlineWidth = outlineWidth.map { .number($0) }
        self.outlineOpacity = outlineOpacity.map { .number($0) }
        self.fillColor = fillColor.map { .string($0) }
        self.fillOpacity = fillOpacity.map { .number($0) }
        self.outlinePosition = outlinePosition
        self.outlineDashArray = outlineDashArray.map { .pattern($0) }
        self.outlineCap = outlineCap
        self.outlineJoin = outlineJoin
        self.pattern = pattern
        self.outlineBlur = outlineBlur.map { .number($0) }
    }

    /// Convenience initializer accepting ramp-capable types and union values directly.
    public init(
        data: String,
        layerId: String? = nil,
        sourceId: String? = nil,
        beforeId: String? = nil,
        minzoom: Double? = nil,
        maxzoom: Double? = nil,
        outline: Bool? = nil,
        outlineColor: MTStringOrZoomStringValues? = nil,
        outlineWidth: MTNumberOrZoomNumberValues? = nil,
        outlineOpacity: MTNumberOrZoomNumberValues? = nil,
        fillColor: MTStringOrZoomStringValues? = nil,
        fillOpacity: MTNumberOrZoomNumberValues? = nil,
        outlinePosition: String? = nil,
        outlineDashArray: MTDashArrayValue? = nil,
        outlineCap: String? = nil,
        outlineJoin: String? = nil,
        pattern: String? = nil,
        outlineBlur: MTNumberOrZoomNumberValues? = nil
    ) {
        self.data = data
        self.layerId = layerId
        self.sourceId = sourceId
        self.beforeId = beforeId
        self.minzoom = minzoom
        self.maxzoom = maxzoom
        self.outline = outline
        self.outlineColor = outlineColor
        self.outlineWidth = outlineWidth
        self.outlineOpacity = outlineOpacity
        self.fillColor = fillColor
        self.fillOpacity = fillOpacity
        self.outlinePosition = outlinePosition
        self.outlineDashArray = outlineDashArray
        self.outlineCap = outlineCap
        self.outlineJoin = outlineJoin
        self.pattern = pattern
        self.outlineBlur = outlineBlur
    }
}
