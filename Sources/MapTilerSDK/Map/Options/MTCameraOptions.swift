//
//  MTCameraOptions.swift
//  MapTilerSDK
//
import CoreLocation

/// Options for controlling the desired location, zoom, bearing, and pitch of the camera.
public struct MTCameraOptions: @unchecked Sendable {
    public var zoom: Double?
    public var bearing: Double?
    public var pitch: Double?

    public init(
        zoom: Double? = nil,
        bearing: Double? = nil,
        pitch: Double? = nil
    ) {
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
    }
}

extension MTCameraOptions: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let zoom {
            try container.encode(zoom, forKey: .zoom)
        }

        if let bearing {
            try container.encode(bearing, forKey: .bearing)
        }

        if let pitch {
            try container.encode(pitch, forKey: .pitch)
        }
    }

    enum CodingKeys: String, CodingKey {
        case zoom
        case bearing
        case pitch
    }
}
