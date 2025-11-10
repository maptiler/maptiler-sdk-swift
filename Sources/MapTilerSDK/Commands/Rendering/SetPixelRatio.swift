//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetPixelRatio.swift
//  MapTilerSDK
//

package struct SetPixelRatio: MTCommand {
    var pixelRatio: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setPixelRatio(\(pixelRatio));"
    }
}
