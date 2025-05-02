//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetPitch.swift
//  MapTilerSDK
//

package struct GetPitch: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getPitch();"
    }
}
