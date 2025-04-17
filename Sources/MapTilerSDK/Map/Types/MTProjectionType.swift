//
//  ProjectionType.swift
//  MapTilerSDK
//

/// Type of projection the map uses.
public enum MTProjectionType: String, Codable {
    /// Mercator projection.
    case mercator

    /// Globe projection.
    case globe
}
