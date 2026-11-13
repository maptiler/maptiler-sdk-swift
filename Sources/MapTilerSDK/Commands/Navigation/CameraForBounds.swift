//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CameraForBounds.swift
//  MapTilerSDK
//

import CoreLocation

package struct CameraForBounds: MTValueCommand {
    var bounds: MTBounds
    var options: MTFitBoundsOptions?

    package func toJS() -> JSString {
        let json = options?.toJSON() ?? "{}"
        let sw = bounds.southWest.toLngLat().toJSON() ?? "{}"
        let ne = bounds.northEast.toLngLat().toJSON() ?? "{}"
        return "JSON.stringify(\(MTBridge.mapObject).cameraForBounds([\(sw), \(ne)], \(json)));"
    }
}
