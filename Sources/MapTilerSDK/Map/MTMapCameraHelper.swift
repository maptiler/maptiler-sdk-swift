//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapCamera.swift
//  MapTilerSDK
//

import CoreLocation

/// Sets combination of center, bearing and pitch, as well as roll and elevation.
public class MTMapCameraHelper {
    /// The geographical centerpoint of the map.
    ///
    /// If center is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to (latitude: 0.0, longitude: 0.0).
    public var centerCoordinate: CLLocationCoordinate2D?

    /// The bearing of the map, measured in degrees counter-clockwise from north.
    ///
    /// If bearing is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public var bearing: Double?

    /// The pitch (tilt) of the map, measured in degrees away from the plane of the screen (0-85).
    ///
    /// If pitch is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public var pitch: Double?

    /// The roll angle of the map, measured in degrees counter-clockwise about the camera boresight.
    ///
    /// If roll is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public var roll: Double?

    /// The elevation of the geographical centerpoint of the map, in meters above sea level.
    ///
    /// If elevation is not specified, SDK will look for it in the map style object.
    /// If it is not specified in the style, it will default to 0.0.
    public var elevation: Double?

    private init(
        centerCoordinate: CLLocationCoordinate2D? = nil,
        bearing: Double? = nil,
        pitch: Double? = nil,
        roll: Double? = nil,
        elevation: Double? = nil
    ) {
        self.centerCoordinate = centerCoordinate
        self.bearing = bearing
        self.pitch = pitch
        self.roll = roll
        self.elevation = elevation
    }

    /// Returns camera object with all properties set to 0.
    public static func getCamera() -> MTMapCameraHelper {
        return MTMapCameraHelper(
            centerCoordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            bearing: 0.0,
            pitch: 0.0,
            roll: 0.0,
            elevation: 0.0
        )
    }

    /// Returns camera object initialized from map style options.
    ///
    /// If any of the properties is not set within the style, it will default to 0.
    public static func getCameraFromMapStyle() -> MTMapCameraHelper {
        return MTMapCameraHelper()
    }

    /// Returns camera object constructed from given options object.
    /// - Parameters:
    ///   - options: MTMapOptions object with initial camera options.
    public static func getCameraWith(_ options: MTMapOptions) -> MTMapCameraHelper {
        return MTMapCameraHelper(
            centerCoordinate: options.center,
            bearing: options.bearing,
            pitch: options.pitch,
            roll: options.roll,
            elevation: options.elevation
        )
    }

    /// Returns camera object with the given center coordinate, bearing, pitch, roll and elevation.
    /// - Parameters:
    ///   - centerCoordinate: Latitude and longitude pair.
    ///   - bearing: Bearing of the map, measured in degrees counter-clockwise from north.
    ///   - pitch: Pitch of the map, measured in degrees away from the plane of the screen (0-85).
    ///   - roll: Roll angle of the map, measured in degrees counter-clockwise about the camera boresight.
    ///   - elevation: Elevation of the initial geographical centerpoint of the map, in meters above sea level.
    public static func cameraLookingAtCenterCoordinate(
        _ centerCoordinate: CLLocationCoordinate2D,
        bearing: Double,
        pitch: Double,
        roll: Double,
        elevation: Double
    ) -> MTMapCameraHelper {
        return MTMapCameraHelper(
            centerCoordinate: centerCoordinate,
            bearing: bearing,
            pitch: pitch,
            roll: roll,
            elevation: elevation
        )
    }

    /// Returns camera object with the given center coordinate, bearing and pitch.
    ///
    /// Looks for roll and elevation in the map's style object.
    /// If they are not specified in the style, they will default to 0.
    /// - Parameters:
    ///   - centerCoordinate: Latitude and longitude pair.
    ///   - bearing: Bearing of the map, measured in degrees counter-clockwise from north.
    ///   - pitch: Pitch of the map, measured in degrees away from the plane of the screen (0-85).
    public static func cameraLookingAtCenterCoordinate(
        _ centerCoordinate: CLLocationCoordinate2D,
        bearing: Double,
        pitch: Double
    ) -> MTMapCameraHelper {
        return MTMapCameraHelper(
            centerCoordinate: centerCoordinate,
            bearing: bearing,
            pitch: pitch
        )
    }
}

extension MTMapCameraHelper {
    /// Returns boolean inidicating whether camera object is equal to the reciever.
    /// - Parameters:
    ///   - camera: MTMapCamera object to compare with.
    public func isEqualToMapCameraHelper(_ camera: MTMapCameraHelper) -> Bool {
        let isCenterCoordinateEqual = self.centerCoordinate == camera.centerCoordinate
        let isBearingEqual = self.bearing == camera.bearing
        let isPitchEqual = self.pitch == camera.pitch
        let isRollEqual = self.roll == camera.roll
        let isElevationEqual = self.elevation == camera.elevation

        return isCenterCoordinateEqual && isBearingEqual && isPitchEqual && isRollEqual && isElevationEqual
    }
}
