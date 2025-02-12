//
//  MTNavigable.swift
//  MapTilerSDK
//

import CoreLocation

/// Defines methods for navigating the map.
@MainActor
public protocol MTNavigable {
    func setBearing(_ bearing: Double) async
    func setCenter(_ center: CLLocationCoordinate2D) async
    func flyTo(_ center: CLLocationCoordinate2D, options: MTFlyToOptions?) async
    func easeTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async
    func jumpTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async
}
