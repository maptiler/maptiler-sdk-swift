//
//  MTMapView+MTNavigable.swift
//  MapTilerSDK
//
//  Created by Sasa Prodribaba on 11. 2. 2025..
//

import CoreLocation

extension MTMapView: MTNavigable {
    /// Sets the bearing of the map.
    ///
    /// The bearing is the compass direction that is "up";
    /// for example, a bearing of 90° orients the map so that east is up.
    /// - Parameters:
    ///   - bearing: The desired bearing.
    public func setBearing(_ bearing: Double) async {
        await runCommand(SetBearing(bearing: bearing))
    }

    /// Sets the map's geographical centerpoint.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    public func setCenter(_ center: CLLocationCoordinate2D) async {
        await runCommand(SetCenter(center: center))
    }

    /// Changes any combination of center, zoom, bearing, and pitch.
    ///
    /// The animation seamlessly incorporates zooming and panning to help the user maintain her bearings
    /// even after traversing a great distance.
    /// - Note: The animation will be skipped, and this will behave equivalently to jumpTo
    /// if the user has the reduced motion accesibility feature enabled,
    /// unless options includes essential: true.
    public func flyTo(_ center: CLLocationCoordinate2D, options: MTFlyToOptions?) async {
        await runCommand(FlyTo(center: center, options: options))
    }

    /// Changes any combination of center, zoom, bearing, pitch, and padding.
    ///
    /// The map will retain its current values for any details not specified in options.
    /// - Note: The transition will happen instantly if the user has enabled the reduced motion accesibility feature,
    /// unless options includes essential: true.
    public func easeTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async {
        await runCommand(EaseTo(center: center, options: options))
    }

    /// Changes any combination of center, zoom, bearing, and pitch, without an animated transition.
    public func jumpTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async {
        await runCommand(JumpTo(center: center, options: options))
    }

    /// Sets the padding in pixels around the viewport.
    public func setPadding(_ options: MTPaddingOptions) async {
        await runCommand(SetPadding(paddingOptions: options))
    }

    /// Sets the value of centerClampedToGround.
    ///
    /// If true, the elevation of the center point will automatically be set to the terrain elevation
    /// (or zero if terrain is not enabled).
    /// If false, the elevation of the center point will default to sea level and will not automatically update.
    /// Needs to be set to false to keep the camera above ground when pitch > 90 degrees.
    /// - Parameters:
    ///   - isCenterClampedToGround: The boolean value indicating if center will be clamped to ground.
    /// - Note: Defaults to true.
    public func setIsCenterClampedToGround(_ isCenterClampedToGround: Bool) async {
        await runCommand(SetCenterClampedToGround(isCenterClampedToGround: isCenterClampedToGround))
    }

    /// Sets the elevation of the map's center point, in meters above sea level.
    /// - Parameters:
    ///   - elevation: The desired elevation.
    /// - Note: Triggers the following events: moveStart and moveEnd.
    public func setCenterElevation(_ elevation: Double) async {
        await runCommand(SetCenterElevation(elevation: elevation))
    }

    /// Sets or clears the map's maximum pitch.
    ///
    /// If the map's current pitch is higher than the new maximum, the map will pitch to the new maximum.
    /// If null is provided, the function removes the current maximum pitch (sets it to 60).
    /// - Parameters:
    ///   - maxPitch: The maximum pitch to set (0-85).
    /// - Throws: A ``MTError`` if maxPitch is out of bounds.
    public func setMaxPitch(_ maxPitch: Double?) async throws {
        try await bridge.execute(SetMaxPitch(maxPitch: maxPitch))
    }

    /// Sets or clears the map's maximum zoom.
    ///
    /// If the map's current zoom level is higher than the new maximum, the map will zoom to the new maximum.
    /// If null or undefined is provided, the function removes the current maximum zoom (sets it to 22).
    /// - Parameters:
    ///   - maxZoom: The maximum zoom level to set.
    /// - Throws: A ``MTError`` if maxZoom is out of bounds.
    public func setMaxZoom(_ maxZoom: Double?) async throws {
        try await bridge.execute(SetMaxZoom(maxZoom: maxZoom))
    }

    /// Sets or clears the map's minimum pitch.
    ///
    /// If the map's current pitch is lower than the new minimum, the map will pitch to the new minimum.
    ///  If null is provided, the function removes the current minimum pitch (i.e. sets it to 0).
    /// - Parameters:
    ///   - minPitch: The minimum pitch to set (0-85)
    /// - Throws: A ``MTError`` if minPitch is out of bounds.
    public func setMinPitch(_ minPitch: Double?) async throws {
        try await bridge.execute(SetMinPitch(minPitch: minPitch))
    }

    /// Sets or clears the map's minimum zoom.
    ///
    /// If the map's current zoom level is lower than the new minimum, the map will zoom to the new minimum.
    /// If null  is provided, the function removes the current minimum zoom (i.e. sets it to -2).
    /// - Parameters:
    ///   - minZoom: The minimum zoom level to set (-2 - 24).
    /// - Throws: A ``MTError`` if minZoom is out of bounds.
    public func setMinZoom(_ minZoom: Double?) async throws {
        try await bridge.execute(SetMinZoom(minZoom: minZoom))
    }

    /// Sets the map's pitch (tilt).
    /// - Parameters:
    ///   - pitch: The pitch to set, measured in degrees away from the plane of the screen (0-60).
    public func setPitch(_ pitch: Double) async {
        await runCommand(SetPitch(pitch: pitch))
    }

    /// Sets the map's roll angle.
    /// - Parameters:
    ///   - roll: The roll to set, measured in degrees about the camera boresight.
    /// - Note: Triggers the following events: moveStart, moveEnd, rollStart, and rollEnd.
    public func setRoll(_ roll: Double) async {
        await runCommand(SetRoll(roll: roll))
    }

    /// Set combination of center, bearing, pitch, roll and elevation.
    public func setViewport(with cameraHelper: MTMapCameraHelper, zoomLevel: Double? = nil) {
        Task {
            if let centerCoordinate = cameraHelper.centerCoordinate {
                await setCenter(centerCoordinate)
            }

            if let bearing = cameraHelper.bearing {
                await setBearing(bearing)
            }

            if let pitch = cameraHelper.pitch {
                await setPitch(pitch)
            }

            if let roll = cameraHelper.roll {
                await setRoll(roll)
            }

            if let elevation = cameraHelper.elevation {
                await setCenterElevation(elevation)
            }

            if let zoomLevel {
                await setZoom(zoomLevel)
            }
        }
    }

    /// Returns the map's current pitch (tilt).
    ///
    /// The map's current pitch, measured in degrees away from the plane of the screen.
    public func getPitch() async -> Double {
        await runCommandWithDoubleReturnValue(GetPitch())
    }
}
