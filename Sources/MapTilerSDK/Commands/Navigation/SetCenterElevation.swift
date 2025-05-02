//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCenterElevation.swift
//  MapTilerSDK
//

package struct SetCenterElevation: MTCommand {
    var elevation: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setCenterElevation(\(elevation));"
    }
}
