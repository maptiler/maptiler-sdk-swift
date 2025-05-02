//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCaching.swift
//  MapTilerSDK
//

package struct SetCaching: MTCommand {
    var shouldCache: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.caching = \(shouldCache);"
    }
}
