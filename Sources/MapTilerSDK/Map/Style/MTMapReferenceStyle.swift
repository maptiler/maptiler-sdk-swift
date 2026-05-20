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
public enum MTMapReferenceStyle: Identifiable, Hashable, Sendable, Codable {
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

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case base
        case customUrl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let baseStr = try container.decodeIfPresent(String.self, forKey: .base) {
            switch baseStr {
            case "streets": self = .streets
            case "satellite": self = .satellite
            case "outdoor": self = .outdoor
            case "winter": self = .winter
            case "dataviz": self = .dataviz
            case "basic": self = .basic
            case "bright": self = .bright
            case "topo": self = .topo
            case "toner": self = .toner
            case "backdrop": self = .backdrop
            case "openStreetMap": self = .openStreetMap
            case "aquarelle": self = .aquarelle
            case "landscape": self = .landscape
            case "ocean": self = .ocean
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .base,
                    in: container,
                    debugDescription: "Unknown base style"
                )
            }
        } else if let urlStr = try container.decodeIfPresent(String.self, forKey: .customUrl),
            let url = URL(string: urlStr) {
            self = .custom(url)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid MTMapReferenceStyle encoding"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .streets: try container.encode("streets", forKey: .base)
        case .satellite: try container.encode("satellite", forKey: .base)
        case .outdoor: try container.encode("outdoor", forKey: .base)
        case .winter: try container.encode("winter", forKey: .base)
        case .dataviz: try container.encode("dataviz", forKey: .base)
        case .basic: try container.encode("basic", forKey: .base)
        case .bright: try container.encode("bright", forKey: .base)
        case .topo: try container.encode("topo", forKey: .base)
        case .toner: try container.encode("toner", forKey: .base)
        case .backdrop: try container.encode("backdrop", forKey: .base)
        case .openStreetMap: try container.encode("openStreetMap", forKey: .base)
        case .aquarelle: try container.encode("aquarelle", forKey: .base)
        case .landscape: try container.encode("landscape", forKey: .base)
        case .ocean: try container.encode("ocean", forKey: .base)
        case .custom(let url): try container.encode(url.absoluteString, forKey: .customUrl)
        }
    }

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

    /// Returns the reference style name.
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

    /// Resolves the concrete MapTiler Cloud style URL for this reference style and optional variant.
    /// Returns `nil` if the configuration is invalid or the custom URL is malformed.
    public func fetchStyleURL(variant: MTMapStyleVariant? = nil, apiKey: String) -> URL? {
        if case let .custom(url) = self {
            return url
        }

        let styleName = self.getName().lowercased()

        var mapId: String
        if let variant = variant, variant != .defaultVariant {
            mapId = "\(styleName)-v2-\(variant.rawValue)"
        } else {
            mapId = "\(styleName)-v2"
        }

        return URL(string: "https://api.maptiler.com/maps/\(mapId)/style.json?key=\(apiKey)")
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
