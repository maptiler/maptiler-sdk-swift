//
//  Coordinates.swift
//  MapTilerSDK
//

import CoreLocation

package typealias LngLat = (lng: Double, lat: Double)

extension CLLocationCoordinate2D: @retroactive Equatable {
    // Bridging - Converts native CLLocationCoordinate2D latitude, longitude pair to LngLat pair based on GeoJSON specs
    package func toLngLat() -> LngLat {
        return (self.longitude, self.latitude)
    }

    package func fromLngLat(lngLat: LngLat) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lngLat.lat, longitude: lngLat.lng)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
