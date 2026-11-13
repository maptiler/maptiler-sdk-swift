//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTCameraOptions.swift
//  MapTilerSDK
//
import CoreLocation

/// Options for controlling the desired location, zoom, bearing, and pitch of the camera.
public struct MTCameraOptions: Sendable {
    /// Geographical center of the map.
    public var center: CLLocationCoordinate2D?

    /// Zoom level of the map.
    public var zoom: Double?

    /// The bearing of the map, measured in degrees counter-clockwise from north.
    public var bearing: Double?

    /// The pitch (tilt) of the map, measured in degrees away from the plane of the screen (0-85).
    public var pitch: Double?

    /// Initializes options.
    public init(
        center: CLLocationCoordinate2D? = nil,
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

        if let center {
            try container.encode(center.toLngLat(), forKey: .center)
        }

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let lngLat = try? container.decodeIfPresent(LngLat.self, forKey: .center) {
            self.center = CLLocationCoordinate2D.fromLngLat(lngLat: lngLat)
        } else if let centerArray = try? container.decodeIfPresent([Double].self, forKey: .center),
                  centerArray.count == 2 {
            self.center = CLLocationCoordinate2D(latitude: centerArray[1], longitude: centerArray[0])
        } else {
            self.center = try container.decodeIfPresent(CLLocationCoordinate2D.self, forKey: .center)
        }

        self.zoom = try container.decodeIfPresent(Double.self, forKey: .zoom)
        self.bearing = try container.decodeIfPresent(Double.self, forKey: .bearing)
        self.pitch = try container.decodeIfPresent(Double.self, forKey: .pitch)
    }

    enum CodingKeys: String, CodingKey {
        case center
        case zoom
        case bearing
        case pitch
    }
}
