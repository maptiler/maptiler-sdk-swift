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
        await MTBridge.shared.execute(SetBearing(bearing: bearing))
    }

    /// Sets the map's geographical centerpoint.
    /// - Parameters:
    ///   - center: The desired center coordinate.
    public func setCenter(_ center: CLLocationCoordinate2D) async {
        await MTBridge.shared.execute(SetCenter(center: center))
    }

    /// Changes any combination of center, zoom, bearing, and pitch.
    ///
    /// The animation seamlessly incorporates zooming and panning to help the user maintain her bearings
    /// even after traversing a great distance.
    /// - Note: The animation will be skipped, and this will behave equivalently to jumpTo
    /// if the user has the reduced motion accesibility feature enabled,
    /// unless options includes essential: true.
    public func flyTo(_ center: CLLocationCoordinate2D, options: MTFlyToOptions?) async {
        await MTBridge.shared.execute(FlyTo(center: center, options: options))
    }

    /// Changes any combination of center, zoom, bearing, pitch, and padding.
    ///
    /// The map will retain its current values for any details not specified in options.
    /// - Note: The transition will happen instantly if the user has enabled the reduced motion accesibility feature,
    /// unless options includes essential: true.
    public func easeTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async {
        await MTBridge.shared.execute(EaseTo(center: center, options: options))
    }

    /// Changes any combination of center, zoom, bearing, and pitch, without an animated transition.
    public func jumpTo(_ center: CLLocationCoordinate2D, options: MTCameraOptions?) async {
        await MTBridge.shared.execute(JumpTo(center: center, options: options))
    }
}
