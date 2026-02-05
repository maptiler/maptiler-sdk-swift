//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHeatmapLayer.swift
//  MapTilerSDK
//

import UIKit

/// A heatmap style layer renders a range of colors to represent the density of points in an area.
public class MTHeatmapLayer: MTLayer, @unchecked Sendable, Codable {
    // MARK: - Core properties

    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .heatmap

    /// Identifier of the source to be used for this layer.
    public var sourceIdentifier: String

    /// The maximum zoom level for the layer. Optional number between 0 and 24.
    public var maxZoom: Double?

    /// The minimum zoom level for the layer. Optional number between 0 and 24.
    public var minZoom: Double?

    /// Layer to use from a vector tile source. Required for vector tile sources; prohibited for others.
    public var sourceLayer: String?

    // MARK: - Paint properties

    /// Defines the color of each pixel based on its density value in a heatmap.
    /// Should generally be an expression using ["heatmap-density"].
    public var color: MTStyleValue?

    /// Similar to heatmap-weight but controls the intensity of the heatmap globally.
    public var intensity: MTStyleValue? = .number(1.0)

    /// The global opacity at which the heatmap layer will be drawn.
    public var opacity: MTStyleValue? = .number(1.0)

    /// Radius of influence of one heatmap point in pixels.
    public var radius: MTStyleValue? = .number(30.0)

    /// A measure of how much an individual point contributes to the heatmap.
    public var weight: MTStyleValue? = .number(1.0)

    // MARK: - Layout properties

    /// Whether this layer is displayed. Defaults to "visible".
    public var visibility: MTLayerVisibility? = .visible

    // MARK: - Optional filter hooks

    /// Inline filter expression to be embedded in the layer JSON.
    public var filterExpression: MTPropertyValue?

    /// Optional filter to apply after the layer is added to the map.
    public var initialFilter: MTPropertyValue?

    // MARK: - Initializers

    /// Initializes the layer with a unique identifier and source identifier.
    public init(identifier: String, sourceIdentifier: String) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
    }

    /// Initializes the layer with all options.
    public init(
        identifier: String,
        sourceIdentifier: String,
        maxZoom: Double? = nil,
        minZoom: Double? = nil,
        sourceLayer: String? = nil,
        color: MTStyleValue? = nil,
        intensity: MTStyleValue? = .number(1.0),
        opacity: MTStyleValue? = .number(1.0),
        radius: MTStyleValue? = .number(30.0),
        weight: MTStyleValue? = .number(1.0),
        visibility: MTLayerVisibility? = .visible
    ) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
        self.color = color
        self.intensity = intensity
        self.opacity = opacity
        self.radius = radius
        self.weight = weight
        self.visibility = visibility
    }

    // MARK: - Codable

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        type = try container.decode(MTLayerType.self, forKey: .type)
        sourceIdentifier = try container.decode(String.self, forKey: .source)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        if container.contains(.paint) {
            let paint = try container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
            color = Self.decodeColorValue(from: paint, key: .color)
            intensity = Self.decodeNumberOrExpression(from: paint, key: .intensity)
            opacity = Self.decodeNumberOrExpression(from: paint, key: .opacity)
            radius = Self.decodeNumberOrExpression(from: paint, key: .radius)
            weight = Self.decodeNumberOrExpression(from: paint, key: .weight)
        }

        if container.contains(.layout) {
            let layout = try container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
            if let visibilityRaw = try layout.decodeIfPresent(String.self, forKey: .visibility) {
                visibility = MTLayerVisibility(rawValue: visibilityRaw)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(identifier, forKey: .identifier)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(sourceIdentifier, forKey: .source)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(sourceLayer, forKey: .sourceLayer)

        // Inline filter expression (as string; unquoted by bridge helper)
        if let filterExpr = filterExpression?.toJS() {
            try container.encode(filterExpr, forKey: .filter)
        }

        // Paint
        var paint = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)

        if let c = color {
            switch c {
            case .expression(let expr):
                try paint.encode(expr.toJS(), forKey: .color)
            case .color(let ui):
                try paint.encode(ui.toHex(), forKey: .color)
            default:
                break
            }
        }

        if let v = intensity {
            switch v {
            case .number(let n):
                try paint.encode(n, forKey: .intensity)
            case .expression(let expr):
                try paint.encode(expr.toJS(), forKey: .intensity)
            default:
                break
            }
        }

        if let v = opacity {
            switch v {
            case .number(let n):
                try paint.encode(n, forKey: .opacity)
            case .expression(let expr):
                try paint.encode(expr.toJS(), forKey: .opacity)
            default:
                break
            }
        }

        if let v = radius {
            switch v {
            case .number(let n):
                try paint.encode(n, forKey: .radius)
            case .expression(let expr):
                try paint.encode(expr.toJS(), forKey: .radius)
            default:
                break
            }
        }

        if let v = weight {
            switch v {
            case .number(let n):
                try paint.encode(n, forKey: .weight)
            case .expression(let expr):
                try paint.encode(expr.toJS(), forKey: .weight)
            default:
                break
            }
        }

        // Layout
        var layout = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layout.encodeIfPresent(
            visibility?.rawValue ?? MTLayerVisibility.visible.rawValue,
            forKey: .visibility
        )
    }

    // MARK: - Decode helpers
    private static func decodeNumberOrExpression(
        from container: KeyedDecodingContainer<PaintCodingKeys>,
        key: PaintCodingKeys
    ) -> MTStyleValue? {
        if let n = try? container.decode(Double.self, forKey: key) {
            return .number(n)
        }
        if let expr = try? container.decode(String.self, forKey: key) {
            return .expression(.rawExpression(expr))
        }
        return nil
    }

    private static func decodeColorValue(
        from container: KeyedDecodingContainer<PaintCodingKeys>,
        key: PaintCodingKeys
    ) -> MTStyleValue? {
        guard let colorVal = try? container.decode(String.self, forKey: key) else {
            return nil
        }
        let trimmed = colorVal.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("[") {
            return .expression(.rawExpression(colorVal))
        }
        if let ui = UIColor(hex: colorVal) {
            return .color(ui)
        }
        return nil
    }

    // MARK: - Coding Keys
    package enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case source
        case maxZoom = "maxzoom"
        case minZoom = "minzoom"
        case sourceLayer = "source-layer"
        case filter
        case paint
        case layout
    }

    package enum PaintCodingKeys: String, CodingKey {
        case color = "heatmap-color"
        case intensity = "heatmap-intensity"
        case opacity = "heatmap-opacity"
        case radius = "heatmap-radius"
        case weight = "heatmap-weight"
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case visibility
    }
}

extension MTHeatmapLayer: Equatable {
    public static func == (lhs: MTHeatmapLayer, rhs: MTHeatmapLayer) -> Bool {
        let isIdEqual = lhs.identifier == rhs.identifier
        let isSourceIdentifierEqual = lhs.sourceIdentifier == rhs.sourceIdentifier
        let isMaxZoomEqual = lhs.maxZoom == rhs.maxZoom
        let isMinZoomEqual = lhs.minZoom == rhs.minZoom
        let sourceLayerEqual = lhs.sourceLayer == rhs.sourceLayer

        return isIdEqual &&
            isSourceIdentifierEqual &&
            isMaxZoomEqual &&
            isMinZoomEqual &&
            sourceLayerEqual
    }
}
