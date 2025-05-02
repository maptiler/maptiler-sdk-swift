//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetSession.swift
//  MapTilerSDK
//

package struct SetSession: MTCommand {
    var shouldEnableSessionLogic: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.session = \(shouldEnableSessionLogic);"
    }
}
