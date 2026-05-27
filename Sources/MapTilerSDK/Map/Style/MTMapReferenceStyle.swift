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
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if let baseStr = try container.decodeIfPresent(String.self, forKey: .base) {
                self = try Self.from(string: baseStr, decoder: decoder)
                return
            } else if let urlStr = try container.decodeIfPresent(String.self, forKey: .customUrl),
                let url = URL(string: urlStr) {
                self = .custom(url)
                return
            }
        }

        // Backward compatibility: try decoding as a single string
        let container = try decoder.singleValueContainer()
        let baseStr = try container.decode(String.self)
        self = try Self.from(string: baseStr, decoder: decoder)
    }

    private static func from(string: String, decoder: Decoder) throws -> MTMapReferenceStyle {
        switch string {
        case "streets": return .streets
        case "satellite": return .satellite
        case "outdoor": return .outdoor
        case "winter": return .winter
        case "dataviz": return .dataviz
        case "basic": return .basic
        case "bright": return .bright
        case "topo": return .topo
        case "toner": return .toner
        case "backdrop": return .backdrop
        case "openStreetMap": return .openStreetMap
        case "aquarelle": return .aquarelle
        case "landscape": return .landscape
        case "ocean": return .ocean
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown base style: \(string)"
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

        let mapId = getMapTilerCloudId(variant: variant)
        return URL(string: "https://api.maptiler.com/maps/\(mapId)/style.json?key=\(apiKey)")
    }

    private func getMapTilerCloudId(variant: MTMapStyleVariant?) -> String {
        let isDefault = variant == nil || variant == .defaultVariant

        switch self {
        case .streets:
            return isDefault ? "streets-v2" : "streets-v2-\(variant!.rawValue)"
        case .outdoor:
            return isDefault ? "outdoor-v2" : "outdoor-v2-\(variant!.rawValue)"
        case .winter:
            return isDefault ? "winter-v2" : "winter-v2-\(variant!.rawValue)"
        case .basic:
            return isDefault ? "basic-v2" : "basic-v2-\(variant!.rawValue)"
        case .bright:
            return isDefault ? "bright-v2" : "bright-v2-\(variant!.rawValue)"
        case .topo:
            return isDefault ? "topo-v2" : "topo-v2-\(variant!.rawValue)"
        case .toner:
            return isDefault ? "toner-v2" : "toner-v2-\(variant!.rawValue)"

        case .satellite:
            return "satellite"
        case .openStreetMap:
            return "openstreetmap"
        case .ocean:
            return "ocean"

        case .dataviz:
            return isDefault ? "dataviz" : "dataviz-\(variant!.rawValue)"
        case .backdrop:
            return isDefault ? "backdrop" : "backdrop-\(variant!.rawValue)"
        case .aquarelle:
            return isDefault ? "aquarelle" : "aquarelle-\(variant!.rawValue)"
        case .landscape:
            return isDefault ? "landscape" : "landscape-\(variant!.rawValue)"

        case .custom:
            return ""
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
