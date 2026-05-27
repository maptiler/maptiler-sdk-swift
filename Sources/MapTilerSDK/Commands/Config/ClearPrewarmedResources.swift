//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ClearPrewarmedResources.swift
//  MapTilerSDK
//

package struct ClearPrewarmedResources: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).clearPrewarmedResources();"
    }
}
