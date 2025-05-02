//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveLayers.swift
//  MapTilerSDK
//

package struct RemoveLayers: MTCommand {
    var layers: [MTLayer]

    package func toJS() -> JSString {
        var jsString = ""

        for layer in layers {
            jsString.append("\(MTBridge.mapObject).removeLayer('\(layer.identifier)');")
        }

        return jsString
    }
}
