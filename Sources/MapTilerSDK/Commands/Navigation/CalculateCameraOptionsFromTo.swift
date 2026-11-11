//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CalculateCameraOptionsFromTo.swift
//  MapTilerSDK
//

import CoreLocation

package struct CalculateCameraOptionsFromTo: MTValueCommand {
    var from: CLLocationCoordinate2D
    var altitudeFrom: Double
    var to: CLLocationCoordinate2D
    var altitudeTo: Double

    package func toJS() -> JSString {
        let fromLngLat = from.toLngLat().toJSON() ?? "{}"
        let toLngLat = to.toLngLat().toJSON() ?? "{}"
        let base = "\(MTBridge.mapObject).calculateCameraOptionsFromTo"
        return "JSON.stringify(\(base)(\(fromLngLat), \(altitudeFrom), \(toLngLat), \(altitudeTo)));"
    }
}
