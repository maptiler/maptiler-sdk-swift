//
//  MTSourceType.swift
//  MapTilerSDK
//

/// Types of sources.
///
/// Sources state which data the map should display.
public enum MTSourceType: String {
    case vector
    case raster
    case rasterDEM = "raster-dem"
    case geojson
    case image
    case video
}
