//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  LngLatToString.swift
//  MapTilerSDK
//

import CoreLocation

package struct LngLatToString: MTValueCommand {
    var coordinate: CLLocationCoordinate2D

    package func toJS() -> JSString {
        return "new \(MTBridge.sdkObject).LngLat(\(coordinate.longitude), \(coordinate.latitude)).toString();"
    }
}
