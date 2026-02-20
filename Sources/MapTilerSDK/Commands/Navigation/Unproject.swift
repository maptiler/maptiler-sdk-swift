//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Unproject.swift
//  MapTilerSDK
//

import CoreLocation

package struct Unproject: MTValueCommand {
    var point: MTPoint

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).unproject([\(point.x), \(point.y)]);"
    }
}
