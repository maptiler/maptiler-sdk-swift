//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLayerCategory.swift
//  MapTilerSDK
//

import Foundation

/// Semantic groups of map layers, independent of the style in use.
///
/// Layers are matched by their vector tile `source-layer` rather than by layer id, so the same category works across
/// MapTiler reference styles and their variants. Both tile schemas used by MapTiler styles are covered:
/// MapTiler Planet v4 (Streets, Outdoor, Winter, Base, Topo) and the OpenMapTiles based schema
/// (OpenStreetMap, Dataviz, Backdrop, Aquarelle, Landscape, Ocean, Satellite hybrid).
/// A category only contains the layers that exist in the current style.
///
/// - Note: In OpenMapTiles based styles roads, railways and ferries share the `transportation` source layer,
///   so they all belong to ``roads`` there; ``transit`` is only populated by v4 styles.
public enum MTLayerCategory: String, CaseIterable, Sendable {
    /// Oceans, lakes, rivers, streams, dams and their labels.
    case water

    /// Forests, woods, grass, scrub, farmland, sand, ice, parks and protected areas.
    case nature

    /// Residential, commercial, industrial, education, hospital, leisure, military and similar areas.
    case landuse

    /// Roads, paths, trails, bridges and their labels.
    case roads

    /// Railways, subways, ferries and aerial lifts.
    case transit

    /// Building footprints, 3D buildings and house numbers.
    case buildings

    /// Airport areas, runways and taxiways.
    case aeroways

    /// Country, state and other administrative boundaries.
    case boundaries

    /// Labels of continents, countries, states, cities, towns, villages and islands.
    case places

    /// Points of interest, transit stations and street furniture.
    case poi

    /// Hillshading, contour lines, bathymetry, landforms, peaks and other relief features.
    case terrain

    /// English display name, suitable for a legend.
    public var defaultName: String {
        switch self {
        case .water: return "Water"
        case .nature: return "Nature"
        case .landuse: return "Land use"
        case .roads: return "Roads"
        case .transit: return "Transit"
        case .buildings: return "Buildings"
        case .aeroways: return "Aeroways"
        case .boundaries: return "Boundaries"
        case .places: return "Places"
        case .poi: return "Points of interest"
        case .terrain: return "Terrain"
        }
    }

    package var sourceLayers: Set<String> {
        switch self {
        case .water:
            return ["water", "waterway", "water_name", "water_label", "water_centroid", "dam"]
        case .nature:
            return [
                "landcover", "globallandcover", "park",
                "forest", "wood", "grass", "scrub", "vegetation", "farmland", "sand", "ice", "tree",
                "protected_area_major_label", "protected_area_minor_label"
            ]
        case .landuse:
            return [
                "landuse",
                "residential", "commercial", "industrial", "construction", "cemetery", "education", "hospital",
                "leisure", "military", "military_label", "parking", "pedestrian", "ski"
            ]
        case .roads:
            return [
                "transportation", "transportation_name",
                "road", "road_label", "road_exit", "bridge", "pier", "pathway", "pathway_label", "trail"
            ]
        case .transit:
            return [
                "railway", "railway_label", "subway", "subway_label", "ferry", "ferry_label",
                "aerialway", "aerialway_label"
            ]
        case .buildings:
            return ["building", "housenumber", "building_number"]
        case .aeroways:
            return ["aeroway", "aerodrome_label", "aviation", "aviation_line"]
        case .boundaries:
            return ["boundary", "country_border", "country_border_disputed", "sub_border"]
        case .places:
            return [
                "place",
                "continent_label", "country_label", "country_disputed_label", "state_label", "city_label",
                "town_label", "place_label", "island_label", "archipelago_label"
            ]
        case .poi:
            return ["poi", "outdoor_poi", "street_furniture"]
        case .terrain:
            return [
                "contour", "contour_ft", "contour_line", "landform",
                "mountain_peak", "peak", "volcano", "saddle", "ridge_label", "cliff", "cliff_label"
            ]
        }
    }

    package var sourceLayerPrefixes: [String] {
        self == .poi ? ["poi_"] : []
    }

    package var layerTypes: Set<MTLayerType> {
        self == .terrain ? [.hillshade] : []
    }

    package var sourceIdHints: [String] {
        self == .terrain ? ["hillshade"] : []
    }

    /// Returns whether `layer` belongs to this category.
    public func matches(_ layer: MTStyleLayerInfo) -> Bool {
        if let sourceLayer = layer.sourceLayer {
            if sourceLayers.contains(sourceLayer) { return true }
            if sourceLayerPrefixes.contains(where: { sourceLayer.hasPrefix($0) }) { return true }
        }
        if let type = layer.type, layerTypes.contains(type) { return true }

        guard let source = layer.source?.lowercased() else { return false }
        return sourceIdHints.contains { source.contains($0) }
    }
}
