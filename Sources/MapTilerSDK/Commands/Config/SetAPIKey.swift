//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetAPIKey.swift
//  MapTilerSDK
//

package struct SetAPIKey: MTCommand {
    var apiKey: String

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.apiKey = '\(apiKey)';"
    }
}
