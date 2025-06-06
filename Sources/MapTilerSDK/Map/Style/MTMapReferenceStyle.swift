//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapReferenceStyle.swift
//  MapTilerSDK
//

import Foundation

/// Defines purpose and guidelines on what information is displayed.
public enum MTMapReferenceStyle: Identifiable, Hashable, Sendable {
    /// Unique id of the style.
    public var id: String { getName() }

    /// The classic default style, perfect for urban areas.
    case streets

    /// High resolution satellite images.
    case satellite

    /// A solid hiking companion, with peaks, parks, isolines and more.
    case outdoor

    /// A map for developing skiing, snowboarding and other winter activities and adventures.
    case winter

    /// A minimalist style for data visualization.
    case dataviz

    /// A minimalist alternative to STREETS, with a touch of flat design.
    case basic

    /// A minimalist style for high contrast navigation.
    case bright

    /// Reference style for topographic study.
    case topo

    /// Reference style for very high contrast stylish maps.
    case toner

    /// Neutral greyscale style with hillshading suitable for colorful terrain-aware visualization.
    case backdrop

    /// Reference style without any variants.
    case openStreetMap

    /// Watercolor map for creative use.
    case aquarelle

    /// Light terrain map for data overlays.
    case landscape

    /// Detailed map of the ocean seafloor and bathymetry.
    case ocean

    /// Custom style from the URL.
    ///
    /// Custom style does not have variants.
    case custom(URL)

    /// Returns all child variants.
    public func getVariants() -> [MTMapStyleVariant]? {
        switch self {
        case .streets:
            return [.defaultVariant, .light, .dark, .pastel, .night]
        case .satellite:
            return [.defaultVariant]
        case .outdoor:
            return [.defaultVariant, .light, .dark]
        case .winter:
            return [.defaultVariant, .light, .dark]
        case .dataviz:
            return [.defaultVariant, .light, .dark]
        case .basic:
            return [.defaultVariant, .light, .dark, .pastel]
        case .bright:
            return [.defaultVariant, .light, .dark, .pastel]
        case .topo:
            return [.defaultVariant, .shiny, .pastel, .topographique]
        case .toner:
            return [.defaultVariant, .background, .lite, .lines]
        case .backdrop:
            return [.defaultVariant, .light, .dark]
        case .openStreetMap:
            return [.defaultVariant]
        case .aquarelle:
            return [.defaultVariant, .dark, .vivid]
        case .landscape:
            return [.defaultVariant, .dark, .vivid]
        case .ocean:
            return [.defaultVariant]
        case .custom:
            return [.defaultVariant]
        }
    }

    /// Returns boolean indicating whether style is custom or pre-made.
    public func isCustom() -> Bool {
        switch self {
        case .custom:
            return true
        default:
            return false
        }
    }

    /// Returns reference style name..
    public func getName() -> String {
        switch self {
        case .streets:
            return "STREETS"
        case .satellite:
            return "SATELLITE"
        case .outdoor:
            return "OUTDOOR"
        case .winter:
            return "WINTER"
        case .dataviz:
            return "DATAVIZ"
        case .basic:
            return "BASIC"
        case .bright:
            return "BRIGHT"
        case .topo:
            return "TOPO"
        case .toner:
            return "TONER"
        case .backdrop:
            return "BACKDROP"
        case .openStreetMap:
            return "OPENSTREETMAP"
        case .aquarelle:
            return "AQUARELLE"
        case .landscape:
            return "LANDSCAPE"
        case .ocean:
            return "OCEAN"
        case .custom(let url):
            return url.absoluteString
        }
    }

    /// Returns all pre-made styles.
    public static func all() -> [MTMapReferenceStyle] {
        return [
            .streets,
            .satellite,
            .outdoor,
            .winter,
            .dataviz,
            .basic,
            .bright,
            .topo,
            .toner,
            .backdrop,
            .aquarelle,
            .landscape,
            .ocean,
            .openStreetMap
        ]
    }
}
