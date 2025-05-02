//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetVerticalFieldOfView.swift
//  MapTilerSDK
//

package struct SetVerticalFieldOfView: MTCommand {
    var degrees: Double = 36.87

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setVerticalFieldOfView(\(degrees));"
    }
}
