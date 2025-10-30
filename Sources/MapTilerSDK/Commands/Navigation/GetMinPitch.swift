//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMinPitch.swift
//  MapTilerSDK
//

package struct GetMinPitch: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getMinPitch();"
    }
}
