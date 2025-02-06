//
//  MTMapReferenceStyle.swift
//  MapTilerSDK
//

/// Defines purpose and guidelines on what information is displayed.
public enum MTMapReferenceStyle: String, @unchecked Sendable {
    /// The classic default style, perfect for urban areas.
    case streets

    /// High resolution satellite images.
    case satellite

    /// High resolution satellite with labels, landmarks, roads and political borders.
    case hybrid

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

    /// Reference style for topographic study
    case topo

    /// Reference style for stylish yet minimalist maps
    case voyager

    /// Reference style for very high contrast stylish maps
    case toner

    /// Neutral greyscale style with hillshading suitable for colorful terrain-aware visualization
    case backdrop

    /// Reference style without any variants
    case openStreetMap
}
