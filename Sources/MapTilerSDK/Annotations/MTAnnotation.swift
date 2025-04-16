//
//  MTAnnotation.swift
//  MapTilerSDK
//

import CoreLocation

/// Protocol requirements for all annotation objects.
public protocol MTAnnotation: Sendable {
    /// Unique id.
    var identifier: String { get }

    /// Geographical coordinates.
    var coordinates: CLLocationCoordinate2D { get }

    /// Sets the coordinates.
    ///  - Parameters:
    ///     - coordinates: Coordinates to set.
    ///     - mapView: Map view to apply to.
    func setCoordinates(_ coordinates: CLLocationCoordinate2D, in mapView: MTMapView) async
}
