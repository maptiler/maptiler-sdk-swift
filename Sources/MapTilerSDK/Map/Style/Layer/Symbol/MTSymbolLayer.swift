//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTSymbolLayer.swift
//  MapTilerSDK
//

import UIKit

/// The symbol style that layer renders icon and text labels at points or along lines on a map. 
public class MTSymbolLayer: MTLayer, @unchecked Sendable, Codable {
    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .symbol

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

    /// Icon to use for the layer.
    public var icon: UIImage?

    /// Enum controlling whether this layer is displayed.
    public var visibility: MTLayerVisibility? = .visible

    /// Optional initial filter to apply after the layer is added to the map.
    public var initialFilter: MTPropertyValue?

    // MARK: - Layout: text properties
    /// Text field (tokens allowed), e.g. "{point_count_abbreviated}"
    public var textField: String?

    /// Text size in px
    public var textSize: Double?

    /// Text allow overlap
    public var textAllowOverlap: Bool?

    /// Text anchor
    public var textAnchor: MTTextAnchor?

    /// Text font stack
    public var textFont: [String]?

    /// Inline filter expression for this layer
    public var filterExpression: MTPropertyValue?

    // MARK: - Paint: text properties
    /// Text color
    public var textColor: UIColor?

    package var iconName: String? {
        return "icon\(identifier)"
    }

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
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
    }

    /// Initializes the layer with the unique identifier and a source identifier.
    public init(
        identifier: String,
        sourceIdentifier: String
    ) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
    }

    // Initializes the layer with all the options.
    public init(
        identifier: String,
        sourceIdentifier: String,
        maxZoom: Double? = nil,
        minZoom: Double? = nil,
        sourceLayer: String? = nil,
        icon: UIImage? = nil,
        visibility: MTLayerVisibility? = .visible
    ) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
        self.icon = icon
        self.visibility = visibility
    }

    // Initializes the layer with the decoder.
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        type = try container.decode(MTLayerType.self, forKey: .type)
        sourceIdentifier = try container.decode(String.self, forKey: .source)
        maxZoom = try container.decode(Double.self, forKey: .maxZoom)
        minZoom = try container.decode(Double.self, forKey: .minZoom)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)

        // LAYOUT
        let layoutContainer = try container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)

        let visibilityString = try layoutContainer.decode(String.self, forKey: .visibility)
        visibility = MTLayerVisibility(rawValue: visibilityString)

        textField = try layoutContainer.decodeIfPresent(String.self, forKey: .textField)
        textSize = try layoutContainer.decodeIfPresent(Double.self, forKey: .textSize)
        textAllowOverlap = try layoutContainer.decodeIfPresent(Bool.self, forKey: .textAllowOverlap)
        if let anchorRaw = try layoutContainer.decodeIfPresent(String.self, forKey: .textAnchor) {
            textAnchor = MTTextAnchor(rawValue: anchorRaw)
        }
        textFont = try layoutContainer.decodeIfPresent([String].self, forKey: .textFont)

        // PAINT
        if container.contains(.paint) {
            let paintContainer = try container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
            if let hex = try paintContainer.decodeIfPresent(String.self, forKey: .textColor) {
                textColor = UIColor(hex: hex)
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

        // LAYOUT
        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)

        try layoutContainer.encodeIfPresent(iconName, forKey: .icon)
        try layoutContainer.encodeIfPresent(
            visibility?.rawValue ?? MTLayerVisibility.visible.rawValue,
            forKey: .visibility
        )
        try layoutContainer.encodeIfPresent(textField, forKey: .textField)
        try layoutContainer.encodeIfPresent(textSize, forKey: .textSize)
        try layoutContainer.encodeIfPresent(textAllowOverlap, forKey: .textAllowOverlap)
        try layoutContainer.encodeIfPresent(textAnchor?.rawValue, forKey: .textAnchor)
        try layoutContainer.encodeIfPresent(textFont, forKey: .textFont)

        // Inline filter expression
        if let filterExpr = filterExpression?.toJS() {
            try container.encode(filterExpr, forKey: .filter)
        }

        // PAINT
        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(textColor?.toHex(), forKey: .textColor)
    }

    package enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case source
        case maxZoom = "maxzoom"
        case minZoom = "minzoom"
        case sourceLayer = "source-layer"
        case layout
        case filter
        case paint
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case icon = "icon-image"
        case visibility
        case textField = "text-field"
        case textSize = "text-size"
        case textAllowOverlap = "text-allow-overlap"
        case textAnchor = "text-anchor"
        case textFont = "text-font"
    }
    package enum PaintCodingKeys: String, CodingKey {
        case textColor = "text-color"
    }
}

extension MTSymbolLayer: Equatable {
    public static func == (lhs: MTSymbolLayer, rhs: MTSymbolLayer) -> Bool {
        let isIdEqual = lhs.identifier == rhs.identifier
        let isSourceIdentifierEqual = lhs.sourceIdentifier == rhs.sourceIdentifier
        let isMaxZoomlEqual = lhs.maxZoom == rhs.maxZoom
        let isMinZoomlEqual = lhs.minZoom == rhs.minZoom
        let sourceLayerEqual = lhs.sourceLayer == rhs.sourceLayer

        return isIdEqual &&
            isSourceIdentifierEqual &&
            isMaxZoomlEqual &&
            isMaxZoomlEqual &&
            isMinZoomlEqual &&
            sourceLayerEqual
    }
}
