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
}
