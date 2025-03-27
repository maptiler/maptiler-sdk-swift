//
//  MTFillLayer.swift
//  MapTilerSDK
//

import UIKit

/// The fill style layer that renders one or more filled (and optionally stroked) polygons on a map. 
public class MTFillLayer: MTLayer, @unchecked Sendable, Codable {
    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .fill

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

    /// Boolean indicating whether or not the fill should be antialiased.
    ///
    /// - Note: Defaults to true.
    public var shouldBeAntialised: Bool? = true

    /// The color of the filled part of this layer.
    ///
    /// - Note: Defaults to black.
    public var color: UIColor? = .black

    /// The opacity of the entire fill layer.
    ///
    /// Optional number between 0 and 1 inclusive.
    /// - Note: Defaults to 1.
    public var opacity: Double? = 1.0

    /// The outline color of the fill.
    ///
    /// Matches the value of fill-color if unspecified.
    public var outlineColor: UIColor?

    /// The geometry’s offset.
    ///
    /// Units in pixels. Values are [x, y] where negatives indicate left and up, respectively.
    ///  - Note: Defaults to [0,0].
    public var translate: [Double]?

    /// Enum controlling the frame of reference for translate.
    public var translateAnchor: MTFillTranslateAnchor? = .map

    /// Key for sorting features.
    ///
    /// Features with a higher sort key will appear above features with a lower sort key.
    public var sortKey: Double?

    /// Enum controlling whether this layer is displayed.
    public var visibility: MTLayerVisibility? = .visible

    /// Initializes the source with unique identifier, source identifier, max and min zoom levels and source layer,
    /// which is required for vector tile sources.
    public init(
        identifier: String,
        sourceIdentifier: String,
        maxZoom: Double,
        minZoom: Double,
        sourceLayer: String? = nil
    ) {
        self.identifier = identifier
        self.type = .fill
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
    }

    /// Initializes the source with the unique identifier and a source identifier.
    public init(
        identifier: String,
        sourceIdentifier: String
    ) {
        self.identifier = identifier
        self.type = .fill
        self.sourceIdentifier = sourceIdentifier
    }

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

        shouldBeAntialised = try paintContainer.decodeIfPresent(Bool.self, forKey: .shouldBeAntialised) ?? false
        opacity = try paintContainer.decode(Double.self, forKey: .opacity)
        translate = try paintContainer.decode([Double].self, forKey: .translate)

        let colorHex = try paintContainer.decode(String.self, forKey: .color)
        color = UIColor(hex: colorHex) ?? .black

        let outlineColorHex = try paintContainer.decode(String.self, forKey: .outlineColor)
        outlineColor = UIColor(hex: outlineColorHex) ?? color

        let anchorString = try paintContainer.decode(String.self, forKey: .translateAnchor)
        translateAnchor = MTFillTranslateAnchor(rawValue: anchorString)

        // LAYOUT

        let layoutContainer = try container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)

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

        try paintContainer.encodeIfPresent(shouldBeAntialised, forKey: .shouldBeAntialised)
        try paintContainer.encodeIfPresent(color?.toHex() ?? UIColor.black.toHex(), forKey: .color)
        try paintContainer.encodeIfPresent(opacity, forKey: .opacity)
        try paintContainer.encodeIfPresent(outlineColor?.toHex() ?? UIColor.black.toHex(), forKey: .outlineColor)
        try paintContainer.encodeIfPresent(translate, forKey: .translate)
        try paintContainer.encodeIfPresent(
            translateAnchor?.rawValue ?? MTFillTranslateAnchor.map.rawValue,
            forKey: .translateAnchor
        )

        // LAYOUT

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)

        try layoutContainer.encodeIfPresent(sortKey, forKey: .sortKey)
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
        case shouldBeAntialised = "fill-antialias"
        case color = "fill-color"
        case opacity = "fill-opacity"
        case outlineColor = "fill-outline-color"
        case translate = "fill-translate"
        case translateAnchor = "fill-translate-anchor"
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case sortKey = "fill-sort-key"
        case visibility
    }
}

extension MTFillLayer: Equatable {
    public static func == (lhs: MTFillLayer, rhs: MTFillLayer) -> Bool {
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
