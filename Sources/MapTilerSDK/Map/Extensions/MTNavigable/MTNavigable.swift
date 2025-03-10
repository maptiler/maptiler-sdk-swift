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
    func setPadding(_ options: MTPaddingOptions) async
    func setIsCenterClampedToGround(_ isCenterClampedToGround: Bool) async
    func setCenterElevation(_ elevation: Double) async
    func setMaxPitch(_ maxPitch: Double?) async throws
    func setMaxZoom(_ maxZoom: Double?) async throws
    func setMinPitch(_ minPitch: Double?) async throws
    func setMinZoom(_ minZoom: Double?) async throws
    func setPitch(_ pitch: Double) async
    func setRoll(_ roll: Double) async
    func getPitch() async -> Double
}
