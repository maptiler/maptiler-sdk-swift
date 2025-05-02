//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetRoll.swift
//  MapTilerSDK
//

package struct SetRoll: MTCommand {
    var roll: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setRoll(\(roll));"
    }
}
