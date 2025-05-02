//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetBearing.swift
//  MapTilerSDK
//

package struct SetBearing: MTCommand {
    var bearing: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setBearing(\(bearing));"
    }
}
