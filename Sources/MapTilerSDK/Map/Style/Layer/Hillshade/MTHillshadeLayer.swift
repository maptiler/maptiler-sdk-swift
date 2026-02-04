//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTHillshadeLayer.swift
//  MapTilerSDK
//

import UIKit

/// A hillshade style layer renders digital elevation model (DEM) data on the client-side.
/// Supports Terrain RGB and Mapzen Terrarium tiles via a `raster-dem` source.
public class MTHillshadeLayer: MTLayer, @unchecked Sendable, Codable {
    // MARK: - Core properties

    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .hillshade

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
    /// Required for vector tile sources; prohibited for all other source types.
    public var sourceLayer: String?

    // MARK: - Paint properties

    /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
    /// Optional color. Defaults to black ("#000000").
    public var accentColor: UIColor? = .black

    /// Intensity of the hillshade. Optional number between 0 and 1 inclusive. Defaults to 0.5.
    public var exaggeration: Double? = 0.5

    /// The shading color of areas that face towards the light source. Defaults to white ("#FFFFFF").
    public var highlightColor: UIColor? = .white

    /// Direction of light source when map is rotated. Defaults to "viewport".
    public var illuminationAnchor: MTHillshadeIlluminationAnchor? = .viewport

    /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport
    /// if hillshade-illumination-anchor is set to viewport and due north if set to map. Defaults to 335.
    public var illuminationDirection: Double? = 335.0

    /// The shading color of areas that face away from the light source. Defaults to black ("#000000").
    public var shadowColor: UIColor? = .black

    // MARK: - Layout properties

    /// Whether this layer is displayed. Defaults to "visible".
    public var visibility: MTLayerVisibility? = .visible

    // MARK: - Initializers

    /// Initializes the layer with required identifiers.
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
        accentColor: UIColor? = .black,
        exaggeration: Double? = 0.5,
        highlightColor: UIColor? = .white,
        illuminationAnchor: MTHillshadeIlluminationAnchor? = .viewport,
        illuminationDirection: Double? = 335.0,
        shadowColor: UIColor? = .black,
        visibility: MTLayerVisibility? = .visible
    ) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
        self.accentColor = accentColor
        self.exaggeration = exaggeration
        self.highlightColor = highlightColor
        self.illuminationAnchor = illuminationAnchor
        self.illuminationDirection = illuminationDirection
        self.shadowColor = shadowColor
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

        // PAINT
        if container.contains(.paint) {
            let paint = try container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)

            if let hex = try paint.decodeIfPresent(String.self, forKey: .accentColor) {
                accentColor = UIColor(hex: hex) ?? .black
            }
            exaggeration = try paint.decodeIfPresent(Double.self, forKey: .exaggeration)
            if let hex = try paint.decodeIfPresent(String.self, forKey: .highlightColor) {
                highlightColor = UIColor(hex: hex) ?? .white
            }
            if let anchorRaw = try paint.decodeIfPresent(String.self, forKey: .illuminationAnchor) {
                illuminationAnchor = MTHillshadeIlluminationAnchor(rawValue: anchorRaw)
            }
            illuminationDirection = try paint.decodeIfPresent(Double.self, forKey: .illuminationDirection)
            if let hex = try paint.decodeIfPresent(String.self, forKey: .shadowColor) {
                shadowColor = UIColor(hex: hex) ?? .black
            }
        }

        // LAYOUT
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

        // PAINT
        var paint = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paint.encodeIfPresent(accentColor?.toHex() ?? UIColor.black.toHex(), forKey: .accentColor)
        try paint.encodeIfPresent(exaggeration, forKey: .exaggeration)
        try paint.encodeIfPresent(highlightColor?.toHex() ?? UIColor.white.toHex(), forKey: .highlightColor)
        try paint.encodeIfPresent(
            illuminationAnchor?.rawValue ?? MTHillshadeIlluminationAnchor.viewport.rawValue,
            forKey: .illuminationAnchor
        )
        try paint.encodeIfPresent(illuminationDirection, forKey: .illuminationDirection)
        try paint.encodeIfPresent(shadowColor?.toHex() ?? UIColor.black.toHex(), forKey: .shadowColor)

        // LAYOUT
        var layout = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layout.encodeIfPresent(
            visibility?.rawValue ?? MTLayerVisibility.visible.rawValue,
            forKey: .visibility
        )
    }

    // MARK: - Coding Keys
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
        case accentColor = "hillshade-accent-color"
        case exaggeration = "hillshade-exaggeration"
        case highlightColor = "hillshade-highlight-color"
        case illuminationAnchor = "hillshade-illumination-anchor"
        case illuminationDirection = "hillshade-illumination-direction"
        case shadowColor = "hillshade-shadow-color"
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case visibility
    }
}
