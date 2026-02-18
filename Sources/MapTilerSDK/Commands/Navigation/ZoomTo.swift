//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ZoomTo.swift
//  MapTilerSDK
//

package struct ZoomTo: MTCommand {
    var zoom: Double
    var options: MTAnimationOptions?

    package func toJS() -> JSString {
        if let options = options {
            let optionsString = options.toJSON()?.replaceEasing() ?? "{}"
            return "\(MTBridge.mapObject).zoomTo(\(zoom), \(optionsString));"
        } else {
            return "\(MTBridge.mapObject).zoomTo(\(zoom));"
        }
    }
}
