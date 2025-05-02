//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Coordinates.swift
//  MapTilerSDK
//

import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    // Bridging - Converts native CLLocationCoordinate2D latitude, longitude pair to LngLat pair based on GeoJSON specs
    package func toLngLat() -> LngLat {
        return LngLat(lng: self.longitude, lat: self.latitude)
    }

    package static func fromLngLat(lngLat: LngLat) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lngLat.lat, longitude: lngLat.lng)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        try container.encode(self.longitude)
        try container.encode(self.latitude)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let latitude = try container.decode(CLLocationDegrees.self)
        let longitude = try container.decode(CLLocationDegrees.self)

        self = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
