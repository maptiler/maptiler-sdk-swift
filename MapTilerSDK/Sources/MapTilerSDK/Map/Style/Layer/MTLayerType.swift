//
//  MTLayerType.swift
//  MapTilerSDK
//

/// Types of layers.
public enum MTLayerType: String, Codable {
    /// A filled polygon with an optional stroked border.
    case fill

    /// A stroked line.
    case line

    /// An icon or a text label.
    case symbol

    /// Raster map textures such as satellite imagery.
    case raster

    /// A filled circle.
    case circle

    /// An extruded (3D) polygon.
    case fillExtrusion = "fill-extrusion"

    /// A heatmap.
    case heatmap

    /// Client-side hillshading visualization based on DEM data.
    case hillshade

    /// The background color or pattern of the map.
    case background
}
