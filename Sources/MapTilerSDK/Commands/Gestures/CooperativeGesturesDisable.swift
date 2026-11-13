//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CooperativeGesturesDisable.swift
//  MapTilerSDK
//

package struct CooperativeGesturesDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).cooperativeGestures.disable();"
    }
}
