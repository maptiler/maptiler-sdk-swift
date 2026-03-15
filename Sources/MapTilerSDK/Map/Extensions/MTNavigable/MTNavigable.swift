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

    /// Rotates the map to a given bearing with an optional animated transition.
    /// - Parameters:
    ///    - bearing: The desired bearing.
    ///    - options: Animation options.
    func rotateTo(_ bearing: Double, options: MTAnimationOptions?) async

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

    /// Fits the camera so that the provided bounds are fully visible within the viewport.
    /// - Parameters:
    ///   - bounds: Geographic bounds to display.
    ///   - options: Additional fit configuration.
    func fitBounds(_ bounds: MTBounds, options: MTFitBoundsOptions?) async

    /// Pans, rotates and zooms the map to to fit the box made by points p0 and p1
    /// once the map is rotated to the specified bearing.
    /// To zoom without rotating, pass in the current map bearing.
    /// - Parameters:
    ///   - p0: First point on screen.
    ///   - p1: Second point on screen.
    ///   - bearing: Desired map bearing at end of animation.
    ///   - options: Additional fit configuration.
    func fitScreenCoordinates(_ p0: MTPoint, _ p1: MTPoint, _ bearing: Double, options: MTFitBoundsOptions?) async

    /// Pans the map by the specified offset.
    /// - Parameters:
    ///    - offset: Offset to pan by.
    func panBy(_ offset: MTPoint) async

    /// Pans the map to the specified location with an animated transition.
    /// - Parameters:
    ///    - coordinates: Coordinates to pan to.
    func panTo(_ coordinates: CLLocationCoordinate2D) async

    /// Stops any ongoing animated transition.
    func stop() async

    /// Snaps the map so that north is up.
    /// - Parameters:
    ///    - animationOptions: Animation options.
    func snapToNorth(animationOptions: MTAnimationOptions?) async

    /// Resets the map bearing to 0 degrees.
    /// - Parameters:
    ///    - animationOptions: Animation options.
    func resetNorth(animationOptions: MTAnimationOptions?) async

    /// Resets the map bearing to 0 and pitch to default.
    /// - Parameters:
    ///    - animationOptions: Animation options.
    func resetNorthPitch(animationOptions: MTAnimationOptions?) async

    /// Sets the padding in pixels around the viewport.
    /// - Parameters:
    ///    - options: Padding options.
    func setPadding(_ options: MTPaddingOptions) async

    /// Returns the current viewport padding as MTPaddingOptions.
    func getPadding() async throws -> MTPaddingOptions

    /// Fits the map to the country-level bounds inferred from the current IP address.
    func fitToIpBounds() async

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

    /// Sets or clears the maximum bounds constraint applied to the map.
    /// - Parameter bounds: Geographic bounds to restrict panning, or ``nil`` to remove the constraint.
    func setMaxBounds(_ bounds: MTBounds?) async throws

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

    /// Returns the map's maximum pitch.
    func getMaxPitch() async -> Double

    /// Returns the map's maximum zoom.
    func getMaxZoom() async -> Double

    /// Returns the map's minimum pitch.
    func getMinPitch() async -> Double

    /// Returns the map's minimum zoom.
    func getMinZoom() async -> Double

    /// Returns the map's current center.
    func getCenter() async -> CLLocationCoordinate2D

    /// Returns the current viewport bounds.
    func getBounds() async -> MTBounds

    /// Returns the maximum allowed bounds constraint if one is set.
    func getMaxBounds() async -> MTBounds?

    /// Returns the state of the center clamped to ground flag.
    func getCenterClampedToGround() async -> Bool

    /// Returns the elevation of the map's center point in meters above sea level.
    func getCenterElevation() async -> Double

    /// Returns the elevation for the point where the camera is looking,
    /// in meters above sea level multiplied by exaggeration.
    func getCameraTargetElevation() async -> Double

    /// Returns the map's current bearing.
    func getBearing() async -> Double

    /// Returns the map's current roll.
    func getRoll() async -> Double

    /// Returns true while any camera movement is active.
    func isMoving() async -> Bool

    /// Returns true while the map is rotating.
    func isRotating() async -> Bool

    /// Returns true while the map is zooming.
    func isZooming() async -> Bool
}
