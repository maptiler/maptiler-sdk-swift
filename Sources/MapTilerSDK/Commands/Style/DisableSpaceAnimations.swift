//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  DisableSpaceAnimations.swift
//  MapTilerSDK
//

package struct DisableSpaceAnimations: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).disableSpaceAnimations();"
    }
}
