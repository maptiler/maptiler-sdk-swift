//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetLayerZoomRange.swift
//  MapTilerSDK
//

package struct SetLayerZoomRange: MTCommand {
    let layerId: String
    let minzoom: Double
    let maxzoom: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setLayerZoomRange('\(layerId)', \(minzoom), \(maxzoom));"
    }
}
