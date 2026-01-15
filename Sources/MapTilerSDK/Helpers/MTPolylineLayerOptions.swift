//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPolylineLayerOptions.swift
//  MapTilerSDK
//

import Foundation

/// Options for building a polyline (line) visualization layer through the helper.
public struct MTPolylineLayerOptions: Codable, Sendable {
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

    // Polyline-specific options
    public var lineColor: MTStringOrZoomStringValues?
    public var lineWidth: MTNumberOrZoomNumberValues?
    public var lineOpacity: MTNumberOrZoomNumberValues?
    public var lineBlur: MTNumberOrZoomNumberValues?
    public var lineGapWidth: MTNumberOrZoomNumberValues?
    public var lineDashArray: MTDashArrayValue?
    public var lineCap: String?
    public var lineJoin: String?
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
        lineColor: String? = nil,
        lineWidth: Double? = nil,
        lineOpacity: Double? = nil,
        lineBlur: Double? = nil,
        lineGapWidth: Double? = nil,
        lineDashArray: String? = nil,
        lineCap: String? = nil,
        lineJoin: String? = nil,
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
        self.lineColor = lineColor.map { .string($0) }
        self.lineWidth = lineWidth.map { .number($0) }
        self.lineOpacity = lineOpacity.map { .number($0) }
        self.lineBlur = lineBlur.map { .number($0) }
        self.lineGapWidth = lineGapWidth.map { .number($0) }
        self.lineDashArray = lineDashArray.map { .pattern($0) }
        self.lineCap = lineCap
        self.lineJoin = lineJoin
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
        lineColor: MTStringOrZoomStringValues? = nil,
        lineWidth: MTNumberOrZoomNumberValues? = nil,
        lineOpacity: MTNumberOrZoomNumberValues? = nil,
        lineBlur: MTNumberOrZoomNumberValues? = nil,
        lineGapWidth: MTNumberOrZoomNumberValues? = nil,
        lineDashArray: MTDashArrayValue? = nil,
        lineCap: String? = nil,
        lineJoin: String? = nil,
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
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.lineOpacity = lineOpacity
        self.lineBlur = lineBlur
        self.lineGapWidth = lineGapWidth
        self.lineDashArray = lineDashArray
        self.lineCap = lineCap
        self.lineJoin = lineJoin
        self.outlineBlur = outlineBlur
    }
}
