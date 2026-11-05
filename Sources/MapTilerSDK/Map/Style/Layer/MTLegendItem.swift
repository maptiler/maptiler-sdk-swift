//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLegendItem.swift
//  MapTilerSDK
//

import Foundation

/// A single legend entry describing one ``MTLayerCategory`` in the current style.
public struct MTLegendItem: Sendable, Equatable {
    /// The category this entry represents.
    public let category: MTLayerCategory

    /// Display name of the entry (defaults to ``MTLayerCategory/defaultName``).
    public let name: String

    /// Style layers belonging to the category, in rendering order.
    public let layerIds: [String]

    /// `true` if at least one of the layers is visible.
    public let isVisible: Bool

    /// Representative CSS color (e.g. `#aad3df`, `hsl(205, 56%, 73%)`), or `nil` if none could be resolved.
    public let color: String?
}

package enum MTLegendColorResolver {
    private static let colorPrefixes = ["#", "rgb(", "rgba(", "hsl(", "hsla("]

    /// Layer types in order of preference for picking a legend swatch, with the paint property holding their color.
    package static let swatchPaintProperties: [(MTLayerType, String)] = [
        (.fill, "fill-color"),
        (.line, "line-color"),
        (.fillExtrusion, "fill-extrusion-color"),
        (.circle, "circle-color"),
        (.hillshade, "hillshade-shadow-color"),
        (.symbol, "text-color")
    ]

    /// Source layers that best represent a category, most representative first (e.g. wood rather than ice for nature).
    private static let preferredSourceLayers: [MTLayerCategory: [String]] = [
        .water: ["water"],
        .nature: ["wood", "forest", "park", "grass", "landcover", "globallandcover"],
        .landuse: ["residential", "landuse"],
        .roads: ["road", "transportation"],
        .transit: ["railway"],
        .boundaries: ["country_border", "boundary"]
    ]

    /// Picks the layer and paint property that best represent `category` visually: the most preferred layer type
    /// first, then the most representative source layer, then rendering order.
    package static func swatchSource(
        for category: MTLayerCategory,
        in layers: [MTStyleLayerInfo]
    ) -> (layer: MTStyleLayerInfo, property: String)? {
        let preferred = preferredSourceLayers[category] ?? []
        let rank = { (layer: MTStyleLayerInfo) -> Int in
            layer.sourceLayer.flatMap { preferred.firstIndex(of: $0) } ?? preferred.count
        }

        for (type, property) in swatchPaintProperties {
            let candidates = layers.filter { $0.type == type }
            // min(by:) keeps the first of equally ranked layers, preserving rendering order.
            if let layer = candidates.min(by: { rank($0) < rank($1) }) {
                return (layer, property)
            }
        }
        return nil
    }

    /// Returns the first literal color found in a property value decoded with `JSONSerialization`. Handles plain
    /// colors as well as zoom expressions (`interpolate`, `step`, `match`, legacy `stops`).
    package static func firstColor(in value: Any?) -> String? {
        switch value {
        case let string as String:
            let lower = string.trimmingCharacters(in: .whitespaces).lowercased()
            return colorPrefixes.contains { lower.hasPrefix($0) } ? string : nil
        case let array as [Any]:
            return array.lazy.compactMap { firstColor(in: $0) }.first
        case let object as [String: Any]:
            return firstColor(in: object["stops"])
                ?? object.keys.sorted().lazy.compactMap { firstColor(in: object[$0]) }.first
        default:
            return nil
        }
    }
}
