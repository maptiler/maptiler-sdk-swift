//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetSky.swift
//  MapTilerSDK
//

package struct SetSky: MTCommand {
    var sky: MTSky
    var options: MTStyleSetterOptions?

    package func toJS() -> JSString {
        let skyString: JSString = sky.toJSON() ?? ""
        let parameters: JSString = options != nil ? "\(skyString),\(options.toJSON() ?? "")" : skyString

        return "\(MTBridge.mapObject).setSky(\(parameters));"
    }
}
