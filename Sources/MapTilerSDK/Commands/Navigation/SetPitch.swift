//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetPitch.swift
//  MapTilerSDK
//

package struct SetPitch: MTCommand {
    var pitch: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setPitch(\(pitch));"
    }
}
