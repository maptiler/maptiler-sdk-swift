//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  DisableTerrain.swift
//  MapTilerSDK
//

package struct DisableTerrain: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).disableTerrain();"
    }
}
