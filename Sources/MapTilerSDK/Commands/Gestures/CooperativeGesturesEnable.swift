//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CooperativeGesturesEnable.swift
//  MapTilerSDK
//

package struct CooperativeGesturesEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).cooperativeGestures.enable();"
    }
}
