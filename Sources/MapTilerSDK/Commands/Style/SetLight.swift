//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetLight.swift
//  MapTilerSDK
//

package struct SetLight: MTCommand {
    var light: MTLight
    var options: MTStyleSetterOptions?

    package func toJS() -> JSString {
        let lightString: JSString = light.toJSON() ?? ""
        let parameters: JSString = options != nil ? "\(lightString),\(options.toJSON() ?? "")" : lightString

        return "\(MTBridge.mapObject).setLight(\(parameters));"
    }
}
