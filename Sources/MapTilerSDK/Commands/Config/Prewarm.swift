//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Prewarm.swift
//  MapTilerSDK
//

package struct Prewarm: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).prewarm();"
    }
}
