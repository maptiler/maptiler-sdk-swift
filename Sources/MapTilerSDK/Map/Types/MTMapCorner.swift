//
//  MTMapCorner.swift
//  MapTilerSDK
//

/// Represents corners of the map.
public enum MTMapCorner: String, Sendable, Codable {
    /// Top left corner of the map.
    case topLeft = "top-left"

    /// Top right corner of the map.
    case topRight = "top-right"

    /// Bottom left corner of the map.
    case bottomLeft = "bottom-left"

    /// Bottom right corner of the map.
    case bottomRight = "bottom-right"
}
