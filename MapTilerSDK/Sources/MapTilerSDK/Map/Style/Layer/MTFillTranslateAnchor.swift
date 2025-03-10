//
//  MTFillTranslateAnchor.swift
//  MapTilerSDK
//

/// Enum controlling the frame of reference for fill translate.
public enum MTFillTranslateAnchor: String {
    /// The fill is translated relative to the map.
    case map

    /// The fill is translated relative to the viewport.
    case viewport
}
