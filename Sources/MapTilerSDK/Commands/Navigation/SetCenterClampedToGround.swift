//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCenterClampedToGround.swift
//  MapTilerSDK
//

package struct SetCenterClampedToGround: MTCommand {
    var isCenterClampedToGround: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setCenterClampedToGround(\(isCenterClampedToGround));"
    }
}
