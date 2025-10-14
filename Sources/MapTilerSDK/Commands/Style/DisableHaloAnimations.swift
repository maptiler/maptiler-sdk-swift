//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  DisableHaloAnimations.swift
//  MapTilerSDK
//

package struct DisableHaloAnimations: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).disableHaloAnimations();"
    }
}
