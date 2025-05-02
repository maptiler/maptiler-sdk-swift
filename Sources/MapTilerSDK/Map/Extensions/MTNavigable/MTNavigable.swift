//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTNavigable.swift
//  MapTilerSDK
//

import CoreLocation

/// Defines methods for navigating the map.
@MainActor
public protocol MTNavigable {
    /// Sets bearing of the map.
    /// - Parameters:
    ///    - bearing: The bearing of the map, measured in degrees counter-clockwise from north.
    func setBearing(_ bearing: Double) async

    /// Sets the geographical center of the map.
    /// - Parameters:
    ///    - center: Geographical center of the map.
    func setCenter(_ center: CLLocationCoordinate2D) async

    /// Changes any combination of center, zoom, bearing, and pitch,
    /// animating the transition along a curve that evokes flight.
    /// - Parameters:
    ///    - center: Geographical center of the map.
    ///    - options: FlyTo options.
    ///    - animationOptions: animation options.
    func flyTo(_ center: CLLocationCoordinate2D, options: MTFlyToOptions?, animationOptions: MTAnimationOptions?) async

    /// Changes any combination of center, zoom, bearing and pitch
    /// with an animated transition between old and new values.
    /// - Parameters:
    ///    - center: Geographical center of the map.
    ///    - options: Camera options.
    ///    - animationOptions: animation options.
    func easeTo(
        _ center: CLLocationCoordinate2D,
        options: MTCameraOptions?,
        animationOptions: MTAnimationOptions?
    ) async

    /// Changes any combination of center, zoom, bearing, and pitch, without an animated transition
    /// - Parameters:
    ///    - center: Geographical center of the map.
    ///    - options: Camera options.
    func jumpTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async

    /// Pans the map by the specified offset.
    /// - Parameters:
    ///    - offset: Offset to pan by.
    func panBy(_ offset: MTPoint) async

    /// Pans the map to the specified location with an animated transition.
    /// - Parameters:
    ///    - coordinates: Coordinates to pan to.
    func panTo(_ coordinates: CLLocationCoordinate2D) async

    /// Sets the padding in pixels around the viewport.
    /// - Parameters:
    ///    - options: Padding options.
    func setPadding(_ options: MTPaddingOptions) async

    /// Sets the center clamped to the ground.
    ///
    /// If true, the elevation of the center point will automatically be set to the
    /// terrain elevation (or zero if terrain is not enabled). If false, the elevation
    /// of the center point will default to sea level and will not automatically update.
    /// - Parameters:
    ///    - isCenterClampedToGround: Boolean indicating whether center is clamped to the ground.
    func setIsCenterClampedToGround(_ isCenterClampedToGround: Bool) async

    /// Sets the elevation of the map's center point, in meters above sea level.
    /// - Parameters:
    ///    - elevation: Desired elevation.
    func setCenterElevation(_ elevation: Double) async

    /// Sets the map's maximum pitch.
    /// - Parameters:
    ///    - maxPitch: Desired pitch.
    func setMaxPitch(_ maxPitch: Double?) async throws

    /// Sets the map's maximum zoom.
    /// - Parameters:
    ///    - maxZoom: Desired zoom.
    func setMaxZoom(_ maxZoom: Double?) async throws

    /// Sets the map's minimum pitch.
    /// - Parameters:
    ///    - minPitch: Desired pitch.
    func setMinPitch(_ minPitch: Double?) async throws

    /// Sets the map's minimum zoom.
    /// - Parameters:
    ///    - minZoom: Desired zoom.
    func setMinZoom(_ minZoom: Double?) async throws

    /// Sets the map's pitch.
    /// - Parameters:
    ///    - pitch: The pitch to set, measured in degrees away from the plane of the screen (0-60).
    func setPitch(_ pitch: Double) async

    /// Sets the map's roll angle.
    /// - Parameters:
    ///    - roll: Desired roll.
    func setRoll(_ roll: Double) async

    /// Returns the map's current pitch.
    func getPitch() async -> Double

    /// Returns the map's current center.
    func getCenter() async -> CLLocationCoordinate2D

    /// Returns the map's current bearing.
    func getBearing() async -> Double

    /// Returns the map's current roll.
    func getRoll() async -> Double
}
