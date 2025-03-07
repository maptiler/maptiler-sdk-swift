//
//  MTLayerType.swift
//  MapTilerSDK
//

/// Types of layers.
public enum MTLayerType: String {
    case fill
    case line
    case symbol
    case raster
    case circle
    case fillExtrusion = "fill-extrusion"
    case heatmap
    case hillshade
    case background
}
