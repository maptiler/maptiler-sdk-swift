//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMath.swift
//  MapTilerSDK
//

import CoreLocation

/// Pure math helpers for geographic calculations, projections, and tile indices.
public struct MTMath {

    /// Radius of the Earth in meters.
    public static let earthRadius: Double = 6378137.0

    /// Circumference of the Earth in meters.
    public static let earthCircumference: Double = 2.0 * .pi * earthRadius

    /// Maximum latitude used for Web Mercator calculations to prevent infinity.
    public static let maxSafeLatitude: Double = 85.05112877980659

    /// Converts degrees to radians.
    public static func toRadians(degrees: Double) -> Double {
        return (degrees * .pi) / 180.0
    }

    /// Converts radians to degrees.
    public static func toDegrees(radians: Double) -> Double {
        return (radians * 180.0) / .pi
    }

    /// Converts a longitude to Web Mercator X coordinate in meters.
    public static func longitudeToMercatorX(longitude: Double) -> Double {
        return (longitude * earthCircumference) / 360.0
    }

    /// Converts a latitude to Web Mercator Y coordinate in meters.
    public static func latitudeToMercatorY(latitude: Double) -> Double {
        let latRad = toRadians(degrees: latitude)
        let y = log(tan((.pi / 4.0) + (latRad / 2.0)))
        return (y * earthCircumference) / (2.0 * .pi)
    }

    /// Converts a WGS84 coordinate to Web Mercator (X, Y) in meters.
    public static func wgs84ToMercator(coordinate: CLLocationCoordinate2D) -> (x: Double, y: Double) {
        (
            longitudeToMercatorX(longitude: coordinate.longitude),
            latitudeToMercatorY(latitude: coordinate.latitude)
        )
    }

    /// Converts a Web Mercator X coordinate in meters to longitude.
    public static func mercatorXToLongitude(x: Double) -> Double {
        return (x * 360.0) / earthCircumference
    }

    /// Converts a Web Mercator Y coordinate in meters to latitude.
    public static func mercatorYToLatitude(y: Double) -> Double {
        let latRad = atan(exp((y * 2.0 * .pi) / earthCircumference)) * 2.0 - (.pi / 2.0)
        return toDegrees(radians: latRad)
    }

    /// Converts a Web Mercator (X, Y) in meters to WGS84 coordinate.
    public static func mercatorToWgs84(x: Double, y: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: mercatorYToLatitude(y: y),
            longitude: mercatorXToLongitude(x: x)
        )
    }

    /// Calculates the Web Mercator tile X coordinate for a given longitude and zoom level.
    public static func longitudeToTileX(longitude: Double, zoom: Double, round: Bool = true) -> Double {
        let n = pow(2.0, zoom)
        let x = ((longitude + 180.0) / 360.0) * n
        return round ? floor(x) : x
    }

    /// Calculates the Web Mercator tile Y coordinate (XYZ scheme) for a given latitude and zoom level.
    public static func latitudeToTileY(latitude: Double, zoom: Double, round: Bool = true) -> Double {
        let n = pow(2.0, zoom)
        let latRad = toRadians(degrees: latitude)
        let secLat = 1.0 / cos(latRad)
        let y = ((1.0 - log(tan(latRad) + secLat) / .pi) / 2.0) * n
        return round ? floor(y) : y
    }

    /// Converts a WGS84 coordinate to Web Mercator tile indices.
    public static func wgs84ToTileIndex(
        coordinate: CLLocationCoordinate2D,
        zoom: Double,
        round: Bool = true
    ) -> (x: Double, y: Double) {
        (
            longitudeToTileX(longitude: coordinate.longitude, zoom: zoom, round: round),
            latitudeToTileY(latitude: coordinate.latitude, zoom: zoom, round: round)
        )
    }

    /// Calculates the great-circle distance between two WGS84 coordinates using the Haversine formula.
    /// - Returns: The distance in meters.
    public static func haversineDistanceWgs84(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = toRadians(degrees: from.latitude)
        let lat2 = toRadians(degrees: to.latitude)
        let deltaLat = toRadians(degrees: to.latitude - from.latitude)
        let deltaLng = toRadians(degrees: to.longitude - from.longitude)

        let a = sin(deltaLat / 2.0) * sin(deltaLat / 2.0) +
            cos(lat1) * cos(lat2) * sin(deltaLng / 2.0) * sin(deltaLng / 2.0)
        let c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))

        return earthRadius * c
    }

    /// Calculates the total cumulated distance of a route made of multiple WGS84 coordinates.
    /// - Returns: The total distance in meters.
    public static func haversineCumulatedDistanceWgs84(route: [CLLocationCoordinate2D]) -> Double {
        guard route.count > 1 else { return 0.0 }
        var distance = 0.0
        for i in 0..<(route.count - 1) {
            distance += haversineDistanceWgs84(from: route[i], to: route[i + 1])
        }
        return distance
    }

    /// Computes an intermediate point between two WGS84 coordinates using the Haversine formula.
    /// - Parameter ratio: A value between 0.0 and 1.0.
    /// - Returns: The intermediate coordinate.
    public static func haversineIntermediateWgs84(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D,
        ratio: Double
    ) -> CLLocationCoordinate2D {
        let lon1 = toRadians(degrees: from.longitude)
        let lat1 = toRadians(degrees: from.latitude)
        let lon2 = toRadians(degrees: to.longitude)
        let lat2 = toRadians(degrees: to.latitude)

        let aValue = sin((lat1 - lat2) / 2.0) * sin((lat1 - lat2) / 2.0) +
            cos(lat1) * cos(lat2) * sin((lon1 - lon2) / 2.0) * sin((lon1 - lon2) / 2.0)
        let d = 2.0 * asin(sqrt(aValue))

        if d == 0.0 { return from }

        let A = sin((1.0 - ratio) * d) / sin(d)
        let B = sin(ratio * d) / sin(d)

        let x = A * cos(lat1) * cos(lon1) + B * cos(lat2) * cos(lon2)
        let y = A * cos(lat1) * sin(lon1) + B * cos(lat2) * sin(lon2)
        let z = A * sin(lat1) + B * sin(lat2)

        let lat3 = atan2(z, sqrt(pow(x, 2) + pow(y, 2)))
        let lon3 = atan2(y, x)

        return CLLocationCoordinate2D(latitude: toDegrees(radians: lat3), longitude: toDegrees(radians: lon3))
    }

    /// Calculates the Earth's circumference at a given latitude in meters.
    public static func circumferenceAtLatitude(latitude: Double) -> Double {
        return earthCircumference * cos(toRadians(degrees: latitude))
    }

    /// Wraps a longitude value to be within the `[-180, 180]` range.
    public static func wrapLongitude(_ longitude: Double) -> Double {
        var lng = longitude.truncatingRemainder(dividingBy: 360.0)
        if lng > 180.0 {
            lng -= 360.0
        } else if lng < -180.0 {
            lng += 360.0
        }
        return lng
    }
}
