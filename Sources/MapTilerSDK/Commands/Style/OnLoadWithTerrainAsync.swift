//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  OnLoadWithTerrainAsync.swift
//  MapTilerSDK
//

package struct OnLoadWithTerrainAsync: MTCommand {
    package func toJS() -> JSString {
        return "await \(MTBridge.mapObject).onLoadWithTerrainAsync();"
    }
}
