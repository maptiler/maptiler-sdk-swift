//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView+MTNavigable.swift
//  MapTilerSDK
//

import CoreLocation

extension MTMapView: MTNavigable {
    /// Sets the bearing of the map.
    ///
    /// The bearing is the compass direction that is "up";
    /// for example, a bearing of 90° orients the map so that east is up.
    /// - Parameters:
    ///   - bearing: The desired bearing.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setBearing(_ bearing: Double, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetBearing(bearing: bearing), completion: completionHandler)
        options?.setBearing(bearing)
    }

    /// Sets the map's geographical centerpoint.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setCenter(
        _ center: CLLocationCoordinate2D,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SetCenter(center: center), completion: completionHandler)
        options?.setCenter(center)
    }

    /// Changes any combination of center, zoom, bearing, and pitch.
    ///
    /// The animation seamlessly incorporates zooming and panning to help the user maintain her bearings
    /// even after traversing a great distance.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    ///   - options: Custom options to use.
    ///   - animationOptions: Optional animation options to use.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: The animation will be skipped, and this will behave equivalently to jumpTo
    /// if the user has the reduced motion accesibility feature enabled,
    /// unless options includes essential: true.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func flyTo(
        _ center: CLLocationCoordinate2D,
        options: MTFlyToOptions?,
        animationOptions: MTAnimationOptions?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            FlyTo(center: center, options: options, animationOptions: animationOptions),
            completion: completionHandler
        )

        self.options?.setCenter(center)
    }

    /// Changes any combination of center, zoom, bearing, pitch, and padding.
    ///
    /// The map will retain its current values for any details not specified in options.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    ///   - options: Custom options to use.
    ///   - animationOptions: Optional animation options to use.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: The transition will happen instantly if the user has enabled the reduced motion accesibility feature,
    /// unless options includes essential: true.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func easeTo(
        _ center: CLLocationCoordinate2D,
        options: MTCameraOptions?,
        animationOptions: MTAnimationOptions?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            EaseTo(
                center: center,
                options: options,
                animationOptions: animationOptions
            ),
            completion: completionHandler
        )

        self.options?.setCenter(center)

        guard let options = options else {
            return
        }

        if let bearing = options.bearing {
            self.options?.setBearing(bearing)
        }

        if let pitch = options.pitch {
            self.options?.setPitch(pitch)
        }

        if let zoom = options.zoom {
            self.options?.setZoom(zoom)
        }
    }

    /// Changes any combination of center, zoom, bearing, and pitch, without an animated transition.
    ///
    /// - Parameters:
    ///   - center: The desired center coordinate.
    ///   - options: Custom options to use.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func jumpTo(
        _ center: CLLocationCoordinate2D,
        options: MTCameraOptions?,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(JumpTo(center: center, options: options), completion: completionHandler)

        self.options?.setCenter(center)

        guard let options = options else {
            return
        }

        if let bearing = options.bearing {
            self.options?.setBearing(bearing)
        }

        if let pitch = options.pitch {
            self.options?.setPitch(pitch)
        }

        if let zoom = options.zoom {
            self.options?.setZoom(zoom)
        }
    }

    /// Sets the padding in pixels around the viewport.
    /// - Parameters:
    ///   - options: Custom options to use.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setPadding(_ options: MTPaddingOptions, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetPadding(paddingOptions: options), completion: completionHandler)
    }

    /// Sets the value of centerClampedToGround.
    ///
    /// If true, the elevation of the center point will automatically be set to the terrain elevation
    /// (or zero if terrain is not enabled).
    /// If false, the elevation of the center point will default to sea level and will not automatically update.
    /// Needs to be set to false to keep the camera above ground when pitch > 90 degrees.
    /// - Parameters:
    ///   - isCenterClampedToGround: The boolean value indicating if center will be clamped to ground.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: Defaults to true.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setIsCenterClampedToGround(
        _ isCenterClampedToGround: Bool,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(
            SetCenterClampedToGround(isCenterClampedToGround: isCenterClampedToGround),
            completion: completionHandler
        )

        options?.setIsCenterClampedToGround(isCenterClampedToGround)
    }

    /// Sets the elevation of the map's center point, in meters above sea level.
    /// - Parameters:
    ///   - elevation: The desired elevation.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: Triggers the following events: moveStart and moveEnd.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setCenterElevation(_ elevation: Double, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetCenterElevation(elevation: elevation), completion: completionHandler)
        options?.setElevation(elevation)
    }

    /// Sets or clears the map's maximum pitch.
    ///
    /// If the map's current pitch is higher than the new maximum, the map will pitch to the new maximum.
    /// If null is provided, the function removes the current maximum pitch (sets it to 60).
    /// - Parameters:
    ///   - maxPitch: The maximum pitch to set (0-85).
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setMaxPitch(_ maxPitch: Double?, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetMaxPitch(maxPitch: maxPitch), completion: completionHandler)

        if let maxPitch = maxPitch {
            options?.setMaxPitch(maxPitch)
        }
    }

    /// Sets or clears the map's maximum zoom.
    ///
    /// If the map's current zoom level is higher than the new maximum, the map will zoom to the new maximum.
    /// If null or undefined is provided, the function removes the current maximum zoom (sets it to 22).
    /// - Parameters:
    ///   - maxZoom: The maximum zoom level to set.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setMaxZoom(_ maxZoom: Double?, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetMaxZoom(maxZoom: maxZoom), completion: completionHandler)

        if let maxZoom = maxZoom {
            options?.setMaxZoom(maxZoom)
        }
    }

    /// Sets or clears the map's minimum pitch.
    ///
    /// If the map's current pitch is lower than the new minimum, the map will pitch to the new minimum.
    ///  If null is provided, the function removes the current minimum pitch (i.e. sets it to 0).
    /// - Parameters:
    ///   - minPitch: The minimum pitch to set (0-85)
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setMinPitch(_ minPitch: Double?, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetMinPitch(minPitch: minPitch), completion: completionHandler)

        if let minPitch = minPitch {
            options?.setMinPitch(minPitch)
        }
    }

    /// Sets or clears the map's minimum zoom.
    ///
    /// If the map's current zoom level is lower than the new minimum, the map will zoom to the new minimum.
    /// If null  is provided, the function removes the current minimum zoom (i.e. sets it to -2).
    /// - Parameters:
    ///   - minZoom: The minimum zoom level to set (-2 - 24).
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setMinZoom(_ minZoom: Double?, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetMinZoom(minZoom: minZoom), completion: completionHandler)

        if let minZoom = minZoom {
            options?.setMinZoom(minZoom)
        }
    }

    /// Sets the map's pitch (tilt).
    /// - Parameters:
    ///   - pitch: The pitch to set, measured in degrees away from the plane of the screen (0-60).
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setPitch(_ pitch: Double, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetPitch(pitch: pitch), completion: completionHandler)

        options?.setPitch(pitch)
    }

    /// Sets the map's roll angle.
    /// - Parameters:
    ///   - roll: The roll to set, measured in degrees about the camera boresight.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: Triggers the following events: moveStart, moveEnd, rollStart, and rollEnd.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setRoll(_ roll: Double, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(SetRoll(roll: roll), completion: completionHandler)

        options?.setRoll(roll)
    }

    /// Set combination of center, bearing, pitch, roll and elevation.
    /// - Parameters:
    ///   - cameraHelper: Helper to use for setting the viewport.
    ///   - zoomLevel: Desired zoom level to set.
    public func setViewport(with cameraHelper: MTMapCameraHelper, zoomLevel: Double? = nil) {
        Task {
            if let centerCoordinate = cameraHelper.centerCoordinate {
                setCenter(centerCoordinate, completionHandler: nil)
            }

            if let bearing = cameraHelper.bearing {
                setBearing(bearing, completionHandler: nil)
            }

            if let pitch = cameraHelper.pitch {
                setPitch(pitch, completionHandler: nil)
            }

            if let roll = cameraHelper.roll {
                setRoll(roll, completionHandler: nil)
            }

            if let elevation = cameraHelper.elevation {
                setCenterElevation(elevation, completionHandler: nil)
            }

            if let zoomLevel {
                setZoom(zoomLevel, completionHandler: nil)
            }
        }
    }

    /// Returns the map's current pitch (tilt).
    ///
    /// The map's current pitch, measured in degrees away from the plane of the screen.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getPitch(completionHandler: @escaping (Result<Double, MTError>) -> Void) {
        runCommandWithDoubleReturnValue(GetPitch(), completion: completionHandler)
    }

    /// Pans the map by the specified offset.
    /// - Parameters:
    ///   - offset: The x and y coordinates by which to pan the map.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func panBy(_ offset: MTPoint, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        runCommand(PanBy(offset: offset), completion: completionHandler)
    }

    /// Pans the map to the specified location with an animated transition.
    /// - Parameters:
    ///   - coordinates: The location to pan the map to.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func panTo(
        _ coordinates: CLLocationCoordinate2D,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(PanTo(coordinates: coordinates), completion: completionHandler)
    }

    /// Returns the map's current center.
    ///
    /// The map's current geographical center.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getCenter(completionHandler: @escaping (Result<CLLocationCoordinate2D, MTError>) -> Void) {
        runCommandWithCoordinateReturnValue(GetCenter(), completion: completionHandler)
    }

    /// Project coordinates to point on the container.
    /// - Parameters:
    ///   - coordinates: The location to project.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func project(
        coordinates: CLLocationCoordinate2D,
        completionHandler: @escaping (Result<CLLocationCoordinate2D, MTError>) -> Void
    ) {
        runCommandWithCoordinateReturnValue(Project(coordinate: coordinates), completion: completionHandler)
    }

    /// Returns the map's current bearing.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getBearing(completionHandler: @escaping (Result<Double, MTError>) -> Void) {
        runCommandWithDoubleReturnValue(GetBearing(), completion: completionHandler)
    }

    /// Returns the map's current roll.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func getRoll(completionHandler: @escaping (Result<Double, MTError>) -> Void) {
        runCommandWithDoubleReturnValue(GetRoll(), completion: completionHandler)
    }
}

// Concurrency
extension MTMapView {
    /// Sets the bearing of the map.
    ///
    /// The bearing is the compass direction that is "up";
    /// for example, a bearing of 90° orients the map so that east is up.
    /// - Parameters:
    ///   - bearing: The desired bearing.
    public func setBearing(_ bearing: Double) async {
        await withCheckedContinuation { continuation in
            setBearing(bearing) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the map's geographical centerpoint.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    public func setCenter(_ center: CLLocationCoordinate2D) async {
        await withCheckedContinuation { continuation in
            setCenter(center) { _ in
                continuation.resume()
            }
        }
    }

    /// Changes any combination of center, zoom, bearing, and pitch.
    ///
    /// The animation seamlessly incorporates zooming and panning to help the user maintain her bearings
    /// even after traversing a great distance.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    ///   - options: Custom options to use.
    ///   - animationOptions: Optional animation options to use.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: The animation will be skipped, and this will behave equivalently to jumpTo
    /// if the user has the reduced motion accesibility feature enabled,
    /// unless options includes essential: true.
    public func flyTo(
        _ center: CLLocationCoordinate2D,
        options: MTFlyToOptions?,
        animationOptions: MTAnimationOptions?
    ) async {
        await withCheckedContinuation { continuation in
            flyTo(center, options: options, animationOptions: animationOptions) { _ in
                continuation.resume()
            }
        }
    }

    /// Changes any combination of center, zoom, bearing, pitch, and padding.
    ///
    /// The map will retain its current values for any details not specified in options.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    ///   - options: Custom options to use.
    ///   - animationOptions: Optional animation options to use.
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: The transition will happen instantly if the user has enabled the reduced motion accesibility feature,
    /// unless options includes essential: true.
    public func easeTo(
        _ center: CLLocationCoordinate2D,
        options: MTCameraOptions?,
        animationOptions: MTAnimationOptions?
    ) async {
        await withCheckedContinuation { continuation in
            easeTo(center, options: options, animationOptions: animationOptions) { _ in
                continuation.resume()
            }
        }
    }

    /// Changes any combination of center, zoom, bearing, and pitch, without an animated transition.
    public func jumpTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async {
        await withCheckedContinuation { continuation in
            jumpTo(center, options: options) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the padding in pixels around the viewport.
    public func setPadding(_ options: MTPaddingOptions) async {
        await withCheckedContinuation { continuation in
            setPadding(options) { _ in
                continuation.resume()
            }
        }
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
        await withCheckedContinuation { continuation in
            setIsCenterClampedToGround(isCenterClampedToGround) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the elevation of the map's center point, in meters above sea level.
    /// - Parameters:
    ///   - elevation: The desired elevation.
    /// - Note: Triggers the following events: moveStart and moveEnd.
    public func setCenterElevation(_ elevation: Double) async {
        await withCheckedContinuation { continuation in
            setCenterElevation(elevation) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets or clears the map's maximum pitch.
    ///
    /// If the map's current pitch is higher than the new maximum, the map will pitch to the new maximum.
    /// If null is provided, the function removes the current maximum pitch (sets it to 60).
    /// - Parameters:
    ///   - maxPitch: The maximum pitch to set (0-85).
    /// - Throws: A ``MTError`` if maxPitch is out of bounds.
    public func setMaxPitch(_ maxPitch: Double?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            setMaxPitch(maxPitch) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Sets or clears the map's maximum zoom.
    ///
    /// If the map's current zoom level is higher than the new maximum, the map will zoom to the new maximum.
    /// If null or undefined is provided, the function removes the current maximum zoom (sets it to 22).
    /// - Parameters:
    ///   - maxZoom: The maximum zoom level to set.
    /// - Throws: A ``MTError`` if maxZoom is out of bounds.
    public func setMaxZoom(_ maxZoom: Double?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            setMaxZoom(maxZoom) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Sets or clears the map's minimum pitch.
    ///
    /// If the map's current pitch is lower than the new minimum, the map will pitch to the new minimum.
    ///  If null is provided, the function removes the current minimum pitch (i.e. sets it to 0).
    /// - Parameters:
    ///   - minPitch: The minimum pitch to set (0-85)
    /// - Throws: A ``MTError`` if minPitch is out of bounds.
    public func setMinPitch(_ minPitch: Double?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            setMinPitch(minPitch) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Sets or clears the map's minimum zoom.
    ///
    /// If the map's current zoom level is lower than the new minimum, the map will zoom to the new minimum.
    /// If null  is provided, the function removes the current minimum zoom (i.e. sets it to -2).
    /// - Parameters:
    ///   - minZoom: The minimum zoom level to set (-2 - 24).
    /// - Throws: A ``MTError`` if minZoom is out of bounds.
    public func setMinZoom(_ minZoom: Double?) async throws {
        try await withCheckedThrowingContinuation { continuation in
            setMinZoom(minZoom) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Sets the map's pitch (tilt).
    /// - Parameters:
    ///   - pitch: The pitch to set, measured in degrees away from the plane of the screen (0-60).
    public func setPitch(_ pitch: Double) async {
        await withCheckedContinuation { continuation in
            setPitch(pitch) { _ in
                continuation.resume()
            }
        }
    }

    /// Sets the map's roll angle.
    /// - Parameters:
    ///   - roll: The roll to set, measured in degrees about the camera boresight.
    /// - Note: Triggers the following events: moveStart, moveEnd, rollStart, and rollEnd.
    public func setRoll(_ roll: Double) async {
        await withCheckedContinuation { continuation in
            setRoll(roll) { _ in
                continuation.resume()
            }
        }
    }

    /// Returns the map's current pitch (tilt).
    ///
    /// The map's current pitch, measured in degrees away from the plane of the screen.
    public func getPitch() async -> Double {
        await withCheckedContinuation { continuation in
            getPitch { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: .nan)
                }
            }
        }
    }

    /// Pans the map by the specified offset.
    /// - Parameters:
    ///   - offset: The x and y coordinates by which to pan the map.
    public func panBy(_ offset: MTPoint) async {
        await withCheckedContinuation { continuation in
            panBy(offset) { _ in
                continuation.resume()
            }
        }
    }

    /// Pans the map to the specified location with an animated transition.
    /// - Parameters:
    ///   - coordinates: The location to pan the map to.
    public func panTo(_ coordinates: CLLocationCoordinate2D) async {
        await withCheckedContinuation { continuation in
            panTo(coordinates) { _ in
                continuation.resume()
            }
        }
    }

    /// Returns the map's current center.
    ///
    /// The map's current geographical center.
    public func getCenter() async -> CLLocationCoordinate2D {
        await withCheckedContinuation { continuation in
            getCenter { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: CLLocationCoordinate2D(latitude: 0, longitude: 0))
                }
            }
        }
    }

    /// Project coordinates to point on the container.
    /// - Parameters:
    ///   - coordinates: The location to project.
    public func project(coordinates: CLLocationCoordinate2D) async -> MTPoint {
        await withCheckedContinuation { continuation in
            project(coordinates: coordinates) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: MTPoint(x: result.latitude, y: result.longitude))
                case .failure:
                    continuation.resume(returning: MTPoint(x: 0, y: 0))
                }
            }
        }
    }

    /// Returns the map's current bearing.
    public func getBearing() async -> Double {
        await withCheckedContinuation { continuation in
            getBearing { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: .nan)
                }
            }
        }
    }

    /// Returns the map's current roll.
    public func getRoll() async -> Double {
        await withCheckedContinuation { continuation in
            getRoll { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure:
                    continuation.resume(returning: .nan)
                }
            }
        }
    }
}
