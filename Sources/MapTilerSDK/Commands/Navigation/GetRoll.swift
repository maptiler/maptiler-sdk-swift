//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetRoll.swift
//  MapTilerSDK
//

package struct GetRoll: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getRoll();"
    }
}
