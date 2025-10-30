//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetCenterClampedToGround.swift
//  MapTilerSDK
//

package struct GetCenterClampedToGround: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getCenterClampedToGround();"
    }
}
