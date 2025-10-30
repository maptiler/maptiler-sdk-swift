//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMaxPitch.swift
//  MapTilerSDK
//

package struct GetMaxPitch: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getMaxPitch();"
    }
}
