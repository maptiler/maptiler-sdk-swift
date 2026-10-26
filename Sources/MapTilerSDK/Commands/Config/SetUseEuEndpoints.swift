//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetUseEuEndpoints.swift
//  MapTilerSDK
//

package struct SetUseEuEndpoints: MTCommand {
    var useEuEndpoints: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.useEuEndpoints = \(useEuEndpoints);"
    }
}
