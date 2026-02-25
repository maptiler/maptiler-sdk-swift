//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetTerrainExaggeration.swift
//  MapTilerSDK
//

package struct SetTerrainExaggeration: MTCommand {
    var exaggeration: Double
    var animate: Bool?

    package func toJS() -> JSString {
        if let animate = animate {
            return "\(MTBridge.mapObject).setTerrainExaggeration(\(exaggeration), \(animate ? "true" : "false"));"
        } else {
            return "\(MTBridge.mapObject).setTerrainExaggeration(\(exaggeration));"
        }
    }
}
