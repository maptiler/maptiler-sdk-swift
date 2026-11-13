//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CooperativeGesturesIsEnabled.swift
//  MapTilerSDK
//

package struct CooperativeGesturesIsEnabled: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).cooperativeGestures.isEnabled();"
    }
}
