//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointLayerOptions.swift
//  MapTilerSDK
//

import Foundation

/// Options for building a point visualization layer through the helper.
///
/// Mirrors the available configuration including common shape options.
public struct MTPointLayerOptions: Codable, Sendable {
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

    // PointLayerOptions
    public var pointColor: MTColorValue?
    public var pointRadius: MTNumberOrZoomNumberValues?
    public var minPointRadius: Double?
    public var maxPointRadius: Double?
    public var property: String?
    public var pointOpacity: MTNumberOrZoomNumberValues?
    public var alignOnViewport: Bool?
    public var cluster: Bool?
    public var showLabel: Bool?
    public var labelColor: MTColorValue?
    public var labelSize: Double?
    public var zoomCompensation: Bool?

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
        pointColor: String? = nil,
        pointRadius: Double? = nil,
        minPointRadius: Double? = nil,
        maxPointRadius: Double? = nil,
        property: String? = nil,
        pointOpacity: Double? = nil,
        alignOnViewport: Bool? = nil,
        cluster: Bool? = nil,
        showLabel: Bool? = nil,
        labelColor: String? = nil,
        labelSize: Double? = nil,
        zoomCompensation: Bool? = nil
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
        self.pointColor = pointColor.map { MTColorValue($0) }
        self.pointRadius = pointRadius.map { .number($0) }
        self.minPointRadius = minPointRadius
        self.maxPointRadius = maxPointRadius
        self.property = property
        self.pointOpacity = pointOpacity.map { .number($0) }
        self.alignOnViewport = alignOnViewport
        self.cluster = cluster
        self.showLabel = showLabel
        self.labelColor = labelColor.map { MTColorValue($0) }
        self.labelSize = labelSize
        self.zoomCompensation = zoomCompensation
    }

    /// Convenience initializer accepting ramp-capable types for outline and point values.
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
        pointColor: MTColorValue? = nil,
        pointRadius: MTNumberOrZoomNumberValues? = nil,
        minPointRadius: Double? = nil,
        maxPointRadius: Double? = nil,
        property: String? = nil,
        pointOpacity: MTNumberOrZoomNumberValues? = nil,
        alignOnViewport: Bool? = nil,
        cluster: Bool? = nil,
        showLabel: Bool? = nil,
        labelColor: MTColorValue? = nil,
        labelSize: Double? = nil,
        zoomCompensation: Bool? = nil
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
        self.pointColor = pointColor
        self.pointRadius = pointRadius
        self.minPointRadius = minPointRadius
        self.maxPointRadius = maxPointRadius
        self.property = property
        self.pointOpacity = pointOpacity
        self.alignOnViewport = alignOnViewport
        self.cluster = cluster
        self.showLabel = showLabel
        self.labelColor = labelColor
        self.labelSize = labelSize
        self.zoomCompensation = zoomCompensation
    }
}
