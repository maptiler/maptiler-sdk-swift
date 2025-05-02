//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Project.swift
//  MapTilerSDK
//

import CoreLocation

package struct Project: MTCommand {
    var coordinate: CLLocationCoordinate2D

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).project([\(coordinate.longitude), \(coordinate.latitude)]);"
    }
}
