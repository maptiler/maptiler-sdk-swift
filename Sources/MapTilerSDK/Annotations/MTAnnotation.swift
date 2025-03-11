//
//  MTAnnotation.swift
//  MapTilerSDK
//

import CoreLocation

public protocol MTAnnotation: Sendable {
    var identifier: String { get }
    var coordinates: CLLocationCoordinate2D { get }

    func setCoordinates(_ coordinates: CLLocationCoordinate2D, in mapView: MTMapView) async
}
