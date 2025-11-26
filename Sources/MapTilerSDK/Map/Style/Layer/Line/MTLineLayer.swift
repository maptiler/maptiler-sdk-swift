//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLineLayer.swift
//  MapTilerSDK
//

import UIKit

/// The line style layer that renders one or more stroked polylines on the map.
public class MTLineLayer: MTLayer, @unchecked Sendable, Codable {
    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .line

    /// Identifier of the source to be used for this layer.
    public var sourceIdentifier: String

    /// The maximum zoom level for the layer.
    ///
    /// Optional number between 0 and 24. At zoom levels equal to or greater than the maxzoom,
    /// the layer will be hidden.
    public var maxZoom: Double?

    /// The minimum zoom level for the layer.
    ///
    /// Optional number between 0 and 24. At zoom levels less than the minzoom,
    /// the layer will be hidden.
    public var minZoom: Double?

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources; prohibited for all other source types,
    /// including GeoJSON sources.
    public var sourceLayer: String?

    /// Blur of the line.
    public var blur: Double? = 0.0

    /// The display of line endings.
    public var cap: MTLineCap? = .butt

    /// The color with which the line will be drawn.
    public var color: UIColor? = .black

    /// The lengths of the alternating dashes and gaps that form the dash pattern.
    public var dashArray: [Double]?

    /// Line casing outside of a line’s actual path.
    public var gapWidth: Double? = 0.0

    /// The gradient with which to color a line feature.
    ///
    /// Can only be used with GeoJSON sources that specify "lineMetrics": true.
    public var gradient: UIColor?

    /// The display of lines when joining.
    public var join: MTLineJoin? = .miter

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    ///
    /// Requires join to be "miter".
    public var miterLimit: Double? = 2.0

    /// The line’s offset.
    ///
    /// For linear features, a positive value offsets the line to the right, relative to the
    /// direction of the line, and a negative value to the left. For polygon features, a
    /// positive value results in an inset, and a negative value results in an outset.
    public var offset: Double? = 0.0

    /// Optional number between 0 and 1 inclusive.
    public var opacity: Double? = 1.0

    /// Used to automatically convert round joins to miter joins for shallow angles.
    public var roundLimit: Double? = 1.05

    /// Feature ordering value.
    ///
    /// Features with a higher sort key will appear above features with a lower sort key.
    public var sortKey: Double?

    /// The geometry’s offset.
    ///
    /// Values are [x, y] where negatives indicate left and up, respectively.
    public var translate: [Double]? = [0.0, 0.0]

    /// Controls the frame of reference for translate.
    public var translateAnchor: MTLineTranslateAnchor? = .map

    /// Width of the line.
    public var width: Double? = 1.0

    /// Enum controlling whether this layer is displayed.
    public var visibility: MTLayerVisibility? = .visible

    /// Optional initial filter to apply after the layer is added to the map.
    public var initialFilter: MTPropertyValue?

    /// Initializes the layer with unique identifier, source identifier, max and min zoom levels and source layer,
    /// which is required for vector tile sources.
    public init(
        identifier: String,
        sourceIdentifier: String,
        maxZoom: Double,
        minZoom: Double,
        sourceLayer: String? = nil
    ) {
        self.identifier = identifier
        self.type = .line
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
    }

    /// Initializes the layer with all options.
    public init(
        identifier: String,
        sourceIdentifier: String,
        maxZoom: Double? = nil,
        minZoom: Double? = nil,
        sourceLayer: String? = nil,
        blur: Double? = 0.0,
        cap: MTLineCap? = .butt,
        color: UIColor? = .black,
        dashArray: [Double]? = nil,
        gapWidth: Double? = 0.0,
        gradient: UIColor? = nil,
        join: MTLineJoin? = .miter,
        miterLimit: Double? = 2.0,
        offset: Double? = 0.0,
        opacity: Double? = 1.0,
        roundLimit: Double? = 1.05,
        sortKey: Double? = nil,
        translate: [Double]? = [0.0, 0.0],
        translateAnchor: MTLineTranslateAnchor? = .map,
        width: Double? = 1.0,
        visibility: MTLayerVisibility? = .visible
    ) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
        self.blur = blur
        self.cap = cap
        self.color = color
        self.dashArray = dashArray
        self.gapWidth = gapWidth
        self.gradient = gradient
        self.join = join
        self.miterLimit = miterLimit
        self.offset = offset
        self.opacity = opacity
        self.roundLimit = roundLimit
        self.sortKey = sortKey
        self.translate = translate
        self.translateAnchor = translateAnchor
        self.width = width
        self.visibility = visibility
    }

    /// Initializes layer from the decoder.
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        type = try container.decode(MTLayerType.self, forKey: .type)
        sourceIdentifier = try container.decode(String.self, forKey: .source)
        maxZoom = try container.decode(Double.self, forKey: .maxZoom)
        minZoom = try container.decode(Double.self, forKey: .minZoom)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)

        // PAINT

        let paintContainer = try container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)

        blur = try paintContainer.decodeIfPresent(Double.self, forKey: .blur)
        dashArray = try paintContainer.decodeIfPresent([Double].self, forKey: .dashArray)
        gapWidth = try paintContainer.decodeIfPresent(Double.self, forKey: .gapWidth)
        offset = try paintContainer.decodeIfPresent(Double.self, forKey: .offset)
        opacity = try paintContainer.decodeIfPresent(Double.self, forKey: .opacity)
        translate = try paintContainer.decodeIfPresent([Double].self, forKey: .translate)
        width = try paintContainer.decodeIfPresent(Double.self, forKey: .width)

        let translateAnchorString = try paintContainer.decode(String.self, forKey: .translateAnchor)
        translateAnchor = MTLineTranslateAnchor(rawValue: translateAnchorString)

        let colorHex = try paintContainer.decode(String.self, forKey: .color)
        color = UIColor(hex: colorHex) ?? .black

        let gradientHex = try paintContainer.decode(String.self, forKey: .gradient)
        gradient = UIColor(hex: gradientHex) ?? .black

        // LAYOUT

        let layoutContainer = try container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)

        let lineCapString = try layoutContainer.decode(String.self, forKey: .cap)
        cap = MTLineCap(rawValue: lineCapString)

        let lineJoinString = try layoutContainer.decode(String.self, forKey: .join)
        join = MTLineJoin(rawValue: lineJoinString)

        miterLimit = try layoutContainer.decode(Double.self, forKey: .miterLimit)
        roundLimit = try layoutContainer.decodeIfPresent(Double.self, forKey: .roundLimit)
        sortKey = try layoutContainer.decode(Double.self, forKey: .sortKey)

        let visibilityString = try layoutContainer.decode(String.self, forKey: .visibility)
        visibility = MTLayerVisibility(rawValue: visibilityString)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(identifier, forKey: .identifier)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(sourceIdentifier, forKey: .source)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(sourceLayer, forKey: .sourceLayer)

        // PAINT

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)

        try paintContainer.encodeIfPresent(blur, forKey: .blur)
        try paintContainer.encodeIfPresent(dashArray, forKey: .dashArray)
        try paintContainer.encodeIfPresent(gapWidth, forKey: .gapWidth)
        try paintContainer.encodeIfPresent(offset, forKey: .offset)
        try paintContainer.encodeIfPresent(opacity, forKey: .opacity)
        try paintContainer.encodeIfPresent(translate, forKey: .translate)
        try paintContainer.encodeIfPresent(width, forKey: .width)

        try paintContainer.encodeIfPresent(
            translateAnchor?.rawValue ?? MTLineTranslateAnchor.map.rawValue,
            forKey: .translateAnchor
        )

        try paintContainer.encodeIfPresent(color?.toHex() ?? UIColor.black.toHex(), forKey: .color)

        if let gradientHex = gradient?.toHex() {
            try paintContainer.encodeIfPresent(gradientHex, forKey: .gradient)
        }

        // LAYOUT

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)

        try layoutContainer.encodeIfPresent(miterLimit, forKey: .miterLimit)
        try layoutContainer.encodeIfPresent(roundLimit, forKey: .roundLimit)
        try layoutContainer.encodeIfPresent(sortKey, forKey: .sortKey)

        try layoutContainer.encodeIfPresent(
            cap?.rawValue ?? MTLineCap.butt.rawValue,
            forKey: .cap
        )

        try layoutContainer.encodeIfPresent(
            join?.rawValue ?? MTLineJoin.miter.rawValue,
            forKey: .join
        )

        try layoutContainer.encodeIfPresent(
            visibility?.rawValue ?? MTLayerVisibility.visible.rawValue,
            forKey: .visibility
        )
    }

    package enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case source
        case maxZoom = "maxzoom"
        case minZoom = "minzoom"
        case sourceLayer = "source-layer"
        case paint
        case layout
    }

    package enum PaintCodingKeys: String, CodingKey {
        case blur = "line-blur"
        case dashArray = "line-dasharray"
        case gapWidth = "line-gap-width"
        case color = "line-color"
        case gradient = "line-gradient"
        case offset = "line-offset"
        case opacity = "line-opacity"
        case translate = "line-translate"
        case translateAnchor = "line-translate-anchor"
        case width = "line-width"
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case cap = "line-cap"
        case join = "line-join"
        case miterLimit = "line-miter-limit"
        case roundLimit = "line-round-limit"
        case sortKey = "line-sort-key"
        case visibility
    }
}
