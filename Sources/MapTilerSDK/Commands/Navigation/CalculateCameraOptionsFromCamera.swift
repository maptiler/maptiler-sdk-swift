//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CalculateCameraOptionsFromCamera.swift
//  MapTilerSDK
//

import CoreLocation

package struct CalculateCameraOptionsFromCamera: MTValueCommand {
    var lngLat: CLLocationCoordinate2D
    var altitude: Double
    var bearing: Double
    var pitch: Double
    var roll: Double

    package func toJS() -> JSString {
        let lngLatJSON = lngLat.toLngLat().toJSON() ?? "{}"
        let base = "\(MTBridge.mapObject).calculateCameraOptionsFromCameraLngLatAltRotation"
        return "JSON.stringify(\(base)(\(lngLatJSON), \(altitude), \(bearing), \(pitch), \(roll)));"
    }
}
