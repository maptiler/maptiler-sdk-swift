//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTCircleLayer.swift
//  MapTilerSDK
//

import UIKit

/// The circle style layer renders one or more filled circles on the map.
public class MTCircleLayer: MTLayer, @unchecked Sendable, Codable {
    // MARK: - Core properties

    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .circle

    /// Identifier of the source to be used for this layer.
    public var sourceIdentifier: String

    /// The maximum zoom level for the layer.
    /// Optional number between 0 and 24. At zoom levels equal to or greater than the maxzoom,
    /// the layer will be hidden.
    public var maxZoom: Double?

    /// The minimum zoom level for the layer.
    /// Optional number between 0 and 24. At zoom levels less than the minzoom,
    /// the layer will be hidden.
    public var minZoom: Double?

    /// Layer to use from a vector tile source.
    /// Required for vector tile sources; prohibited for all other source types,
    /// including GeoJSON sources.
    public var sourceLayer: String?

    // MARK: - Paint properties

    /// Amount to blur the circle. Default 0.
    public var blur: Double? = 0.0

    /// The fill color of the circle (constant or expression).
    public var color: MTStyleValue?

    /// The opacity at which the circle will be drawn. Default 1.
    public var opacity: Double? = 1.0

    /// Circle radius in pixels (constant or expression).
    public var radius: MTStyleValue?

    /// The stroke color of the circle’s outline.
    public var strokeColor: UIColor? = .black

    /// The opacity of the circle’s outline.
    public var strokeOpacity: Double? = 1.0

    /// The width of the circle’s outline in pixels.
    public var strokeWidth: Double? = 0.0

    /// The geometry’s offset. Values are [x, y] where negatives indicate left and up.
    public var translate: [Double]? = [0.0, 0.0]

    /// Controls the frame of reference for translate.
    public var translateAnchor: MTCircleTranslateAnchor? = .map

    /// Orientation of circle when map is pitched.
    /// Defaults to "viewport".
    public var pitchAlignment: MTCirclePitchAlignment? = .viewport

    /// Controls scaling behavior of the circle when the map is pitched.
    /// Defaults to "map".
    public var pitchScale: MTCirclePitchScale? = .map

    // MARK: - Layout properties

    /// Feature ordering value. Features with a higher sort key will appear above features with a lower sort key.
    public var sortKey: Double?

    /// Enum controlling whether this layer is displayed.
    public var visibility: MTLayerVisibility? = .visible

    /// Optional initial filter to apply after the layer is added to the map.
    public var initialFilter: MTPropertyValue?

    // MARK: - Initial paint expressions (applied after add)
    /// Circle color can be a constant or an expression.
    public var circleColor: MTStyleValue?

    /// Circle radius can be a constant or an expression.
    public var circleRadius: MTStyleValue?

    /// Filter expression to be embedded inline in layer JSON.
    public var filterExpression: MTPropertyValue?

    /// Optional filter to apply to this layer.
    public var filter: MTPropertyValue?

    // MARK: - Initializers

    /// Initializes the layer with unique identifier and source identifier.
    public init(
        identifier: String,
        sourceIdentifier: String
    ) {
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
        blur: Double? = 0.0,
        color: MTStyleValue? = nil,
        opacity: Double? = 1.0,
        radius: MTStyleValue? = nil,
        strokeColor: UIColor? = .black,
        strokeOpacity: Double? = 1.0,
        strokeWidth: Double? = 0.0,
        translate: [Double]? = [0.0, 0.0],
        translateAnchor: MTCircleTranslateAnchor? = .map,
        sortKey: Double? = nil,
        visibility: MTLayerVisibility? = .visible
    ) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
        self.blur = blur
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.strokeColor = strokeColor
        self.strokeOpacity = strokeOpacity
        self.strokeWidth = strokeWidth
        self.translate = translate
        self.translateAnchor = translateAnchor
        self.sortKey = sortKey
        self.visibility = visibility
    }

    // MARK: - Codable

    /// Initializes the layer from the decoder.
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
            try decodePaint(from: paint)
        }

        if container.contains(.layout) {
            let layout = try container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
            decodeLayout(from: layout)
        }
    }

    private func decodePaint(from paint: KeyedDecodingContainer<PaintCodingKeys>) throws {
        blur = try paint.decodeIfPresent(Double.self, forKey: .blur)
        opacity = try paint.decodeIfPresent(Double.self, forKey: .opacity)

        if let r = try? paint.decode(Double.self, forKey: .radius) {
            radius = .number(r)
        } else if let rExpr = try? paint.decode(String.self, forKey: .radius) {
            radius = .expression(.rawExpression(rExpr))
        }

        strokeOpacity = try paint.decodeIfPresent(Double.self, forKey: .strokeOpacity)
        strokeWidth = try paint.decodeIfPresent(Double.self, forKey: .strokeWidth)
        translate = try paint.decodeIfPresent([Double].self, forKey: .translate)

        if let translateAnchorRaw = try paint.decodeIfPresent(String.self, forKey: .translateAnchor) {
            translateAnchor = MTCircleTranslateAnchor(rawValue: translateAnchorRaw)
        }

        if let colorVal = try? paint.decode(String.self, forKey: .color) {
            if colorVal.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("[") {
                color = .expression(.rawExpression(colorVal))
            } else if let ui = UIColor(hex: colorVal) {
                color = .color(ui)
            }
        }

        if let strokeColorHex = try paint.decodeIfPresent(String.self, forKey: .strokeColor) {
            strokeColor = UIColor(hex: strokeColorHex) ?? .black
        }

        if let pitchAlignmentRaw = try paint.decodeIfPresent(String.self, forKey: .pitchAlignment) {
            pitchAlignment = MTCirclePitchAlignment(rawValue: pitchAlignmentRaw)
        }

        if let pitchScaleRaw = try paint.decodeIfPresent(String.self, forKey: .pitchScale) {
            pitchScale = MTCirclePitchScale(rawValue: pitchScaleRaw)
        }
    }

    private func decodeLayout(from layout: KeyedDecodingContainer<LayoutCodingKeys>) {
        sortKey = try? layout.decodeIfPresent(Double.self, forKey: .sortKey)
        if let visibilityRaw = try? layout.decodeIfPresent(String.self, forKey: .visibility) {
            visibility = MTLayerVisibility(rawValue: visibilityRaw ?? "visible")
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

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(blur, forKey: .blur)
        try paintContainer.encodeIfPresent(opacity, forKey: .opacity)
        if let r = radius {
            switch r {
            case .number(let n):
                try paintContainer.encode(n, forKey: .radius)
            case .expression(let expr):
                try paintContainer.encode(expr.toJS(), forKey: .radius)
            default:
                break
            }
        }
        try paintContainer.encodeIfPresent(strokeOpacity, forKey: .strokeOpacity)
        try paintContainer.encodeIfPresent(strokeWidth, forKey: .strokeWidth)
        try paintContainer.encodeIfPresent(translate, forKey: .translate)
        try paintContainer.encodeIfPresent(
            translateAnchor?.rawValue ?? MTCircleTranslateAnchor.map.rawValue,
            forKey: .translateAnchor
        )
        if let styleVal = color {
            switch styleVal {
            case .expression(let expr):
                try paintContainer.encode(expr.toJS(), forKey: .color)
            case .color(let uiColor):
                try paintContainer.encode(uiColor.toHex(), forKey: .color)
            default:
                break
            }
        }
        try paintContainer.encodeIfPresent(strokeColor?.toHex() ?? UIColor.black.toHex(), forKey: .strokeColor)
        try paintContainer.encodeIfPresent(
            pitchAlignment?.rawValue ?? MTCirclePitchAlignment.viewport.rawValue,
            forKey: .pitchAlignment
        )
        try paintContainer.encodeIfPresent(
            pitchScale?.rawValue ?? MTCirclePitchScale.map.rawValue,
            forKey: .pitchScale
        )

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encodeIfPresent(sortKey, forKey: .sortKey)
        try layoutContainer.encodeIfPresent(
            visibility?.rawValue ?? MTLayerVisibility.visible.rawValue,
            forKey: .visibility
        )

        // Top-level filter expression (as string; will be unquoted in bridge)
        if let filterExpr = filterExpression?.toJS() {
            try container.encode(filterExpr, forKey: .filter)
        }

        // (radius handled above)
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
        case blur = "circle-blur"
        case color = "circle-color"
        case opacity = "circle-opacity"
        case radius = "circle-radius"
        case strokeColor = "circle-stroke-color"
        case strokeOpacity = "circle-stroke-opacity"
        case strokeWidth = "circle-stroke-width"
        case translate = "circle-translate"
        case translateAnchor = "circle-translate-anchor"
        case pitchAlignment = "circle-pitch-alignment"
        case pitchScale = "circle-pitch-scale"
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case sortKey = "circle-sort-key"
        case visibility
    }
}

extension MTCircleLayer: Equatable {
    public static func == (lhs: MTCircleLayer, rhs: MTCircleLayer) -> Bool {
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
