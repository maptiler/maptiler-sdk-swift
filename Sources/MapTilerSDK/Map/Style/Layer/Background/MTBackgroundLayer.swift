//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTBackgroundLayer.swift
//  MapTilerSDK
//

import UIKit

/// The background style layer covers the entire map.
/// Use a background style layer to configure a color or pattern to show below all other map content.
/// If the background layer is transparent or omitted from the style, any part of the map view that
/// does not show another style layer is transparent.
public class MTBackgroundLayer: MTLayer, @unchecked Sendable, Codable {
    // MARK: - Core properties

    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .background

    /// Background layers have no source. This placeholder satisfies the `MTLayer` protocol.
    /// It is ignored during encoding/decoding and by the style bridge.
    public var sourceIdentifier: String = ""

    /// The maximum zoom level for the layer.
    /// Optional number between 0 and 24. At zoom levels equal to or greater than the maxzoom,
    /// the layer will be hidden.
    public var maxZoom: Double?

    /// The minimum zoom level for the layer.
    /// Optional number between 0 and 24. At zoom levels less than the minzoom,
    /// the layer will be hidden.
    public var minZoom: Double?

    /// Background layers have no source layer; present only to satisfy `MTLayer` protocol.
    public var sourceLayer: String?

    // MARK: - Paint properties

    /// The color with which the background will be drawn.
    /// Can be a constant color or an expression.
    /// Defaults to black.
    public var color: MTStyleValue? = .color(.black)

    /// The opacity at which the background will be drawn.
    /// Optional number between 0 and 1 inclusive. Defaults to 1.
    public var opacity: Double? = 1.0

    /// Name of image in sprite to use for drawing an image background.
    /// For seamless patterns, image width and height must be a factor of two.
    public var pattern: String?

    // MARK: - Layout properties

    /// Whether this layer is displayed. Defaults to "visible".
    public var visibility: MTLayerVisibility? = .visible

    // MARK: - Initializers

    /// Initializes the background layer with an identifier.
    public init(identifier: String) {
        self.identifier = identifier
    }

    /// Initializes the background layer with all options.
    public init(
        identifier: String,
        maxZoom: Double? = nil,
        minZoom: Double? = nil,
        color: MTStyleValue? = .color(.black),
        opacity: Double? = 1.0,
        pattern: String? = nil,
        visibility: MTLayerVisibility? = .visible
    ) {
        self.identifier = identifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.color = color
        self.opacity = opacity
        self.pattern = pattern
        self.visibility = visibility
    }

    // MARK: - Codable

    /// Initializes layer from the decoder.
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        type = try container.decode(MTLayerType.self, forKey: .type)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)

        if container.contains(.paint) {
            let paint = try container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)

            if let colorVal = try? paint.decode(String.self, forKey: .color) {
                if colorVal.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("[") {
                    color = .expression(.rawExpression(colorVal))
                } else if let ui = UIColor(hex: colorVal) {
                    color = .color(ui)
                }
            }

            opacity = try paint.decodeIfPresent(Double.self, forKey: .opacity)
            pattern = try paint.decodeIfPresent(String.self, forKey: .pattern)
        }

        if container.contains(.layout) {
            let layout = try container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
            if let visRaw = try layout.decodeIfPresent(String.self, forKey: .visibility) {
                visibility = MTLayerVisibility(rawValue: visRaw)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(identifier, forKey: .identifier)
        try container.encode(type.rawValue, forKey: .type)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)

        // PAINT
        var paint = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        if let styleVal = color {
            switch styleVal {
            case .expression(let expr):
                try paint.encode(expr.toJS(), forKey: .color)
            case .color(let uiColor):
                try paint.encode(uiColor.toHex(), forKey: .color)
            default:
                break
            }
        }
        try paint.encodeIfPresent(opacity, forKey: .opacity)
        try paint.encodeIfPresent(pattern, forKey: .pattern)

        // LAYOUT
        var layout = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layout.encodeIfPresent(
            visibility?.rawValue ?? MTLayerVisibility.visible.rawValue,
            forKey: .visibility
        )
    }

    // MARK: - Coding keys
    package enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case type
        case maxZoom = "maxzoom"
        case minZoom = "minzoom"
        case paint
        case layout
    }

    package enum PaintCodingKeys: String, CodingKey {
        case color = "background-color"
        case opacity = "background-opacity"
        case pattern = "background-pattern"
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case visibility
    }
}
