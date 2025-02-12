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
}
