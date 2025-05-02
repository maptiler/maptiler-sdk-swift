//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCenter.swift
//  MapTilerSDK
//
import CoreLocation

package struct SetCenter: MTCommand {
    var center: CLLocationCoordinate2D

    package func toJS() -> JSString {
        let centerLngLat: LngLat = center.toLngLat()
        return "\(MTBridge.mapObject).setCenter([\(centerLngLat.lng), \(centerLngLat.lat)]);"
    }
}
