//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRasterLayer.swift
//  MapTilerSDK
//

import Foundation

/// The raster style layer renders raster map textures such as imagery.
public class MTRasterLayer: MTLayer, @unchecked Sendable, Codable {
    /// Unique layer identifier.
    public var identifier: String

    /// Type of the layer.
    public private(set) var type: MTLayerType = .raster

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

    /// Increase or reduce the brightness of the image. The value is the maximum brightness.
    /// Optional number between 0 and 1 inclusive. Defaults to 1.
    public var brightnessMax: Double? = 1.0

    /// Increase or reduce the brightness of the image. The value is the minimum brightness.
    /// Optional number between 0 and 1 inclusive. Defaults to 0.
    public var brightnessMin: Double? = 0.0

    /// Increase or reduce the contrast of the image.
    /// Optional number between -1 and 1 inclusive. Defaults to 0.
    public var contrast: Double? = 0.0

    /// Fade duration when a new tile is added. Units in milliseconds. Defaults to 300.
    public var fadeDuration: Double? = 300.0

    /// Rotates hues around the color wheel. Units in degrees. Defaults to 0.
    public var hueRotate: Double? = 0.0

    /// The opacity at which the image will be drawn.
    /// Optional number between 0 and 1 inclusive. Defaults to 1.
    public var opacity: Double? = 1.0

    /// The resampling/interpolation method to use for overscaling.
    /// Defaults to "linear".
    public var resampling: MTRasterResampling? = .linear

    /// Increase or reduce the saturation of the image.
    /// Optional number between -1 and 1 inclusive. Defaults to 0.
    public var saturation: Double? = 0.0

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
        brightnessMax: Double? = 1.0,
        brightnessMin: Double? = 0.0,
        contrast: Double? = 0.0,
        fadeDuration: Double? = 300.0,
        hueRotate: Double? = 0.0,
        opacity: Double? = 1.0,
        resampling: MTRasterResampling? = .linear,
        saturation: Double? = 0.0,
        visibility: MTLayerVisibility? = .visible
    ) {
        self.identifier = identifier
        self.sourceIdentifier = sourceIdentifier
        self.maxZoom = maxZoom
        self.minZoom = minZoom
        self.sourceLayer = sourceLayer
        self.brightnessMax = brightnessMax
        self.brightnessMin = brightnessMin
        self.contrast = contrast
        self.fadeDuration = fadeDuration
        self.hueRotate = hueRotate
        self.opacity = opacity
        self.resampling = resampling
        self.saturation = saturation
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
            let paintContainer = try container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)

            brightnessMax = try paintContainer.decodeIfPresent(Double.self, forKey: .brightnessMax)
            brightnessMin = try paintContainer.decodeIfPresent(Double.self, forKey: .brightnessMin)
            contrast = try paintContainer.decodeIfPresent(Double.self, forKey: .contrast)
            fadeDuration = try paintContainer.decodeIfPresent(Double.self, forKey: .fadeDuration)
            hueRotate = try paintContainer.decodeIfPresent(Double.self, forKey: .hueRotate)
            opacity = try paintContainer.decodeIfPresent(Double.self, forKey: .opacity)
            if let resamplingRaw = try paintContainer.decodeIfPresent(String.self, forKey: .resampling) {
                resampling = MTRasterResampling(rawValue: resamplingRaw)
            }
            saturation = try paintContainer.decodeIfPresent(Double.self, forKey: .saturation)
        }

        // LAYOUT
        if container.contains(.layout) {
            let layoutContainer = try container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
            if let visibilityRaw = try layoutContainer.decodeIfPresent(String.self, forKey: .visibility) {
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
        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(brightnessMax, forKey: .brightnessMax)
        try paintContainer.encodeIfPresent(brightnessMin, forKey: .brightnessMin)
        try paintContainer.encodeIfPresent(contrast, forKey: .contrast)
        try paintContainer.encodeIfPresent(fadeDuration, forKey: .fadeDuration)
        try paintContainer.encodeIfPresent(hueRotate, forKey: .hueRotate)
        try paintContainer.encodeIfPresent(opacity, forKey: .opacity)
        try paintContainer.encodeIfPresent(
            resampling?.rawValue ?? MTRasterResampling.linear.rawValue,
            forKey: .resampling
        )
        try paintContainer.encodeIfPresent(saturation, forKey: .saturation)

        // LAYOUT
        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encodeIfPresent(
            visibility?.rawValue ?? MTLayerVisibility.visible.rawValue,
            forKey: .visibility
        )
    }

    // MARK: - Coding keys

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
        case brightnessMax = "raster-brightness-max"
        case brightnessMin = "raster-brightness-min"
        case contrast = "raster-contrast"
        case fadeDuration = "raster-fade-duration"
        case hueRotate = "raster-hue-rotate"
        case opacity = "raster-opacity"
        case resampling = "raster-resampling"
        case saturation = "raster-saturation"
    }

    package enum LayoutCodingKeys: String, CodingKey {
        case visibility
    }
}
