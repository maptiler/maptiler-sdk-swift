//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Wrap.swift
//  MapTilerSDK
//

import CoreLocation

package struct Wrap: MTValueCommand {
    var coordinate: CLLocationCoordinate2D

    package func toJS() -> JSString {
        return "new \(MTBridge.sdkObject).LngLat(\(coordinate.longitude), \(coordinate.latitude)).wrap();"
    }
}
