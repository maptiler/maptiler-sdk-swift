//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetTerrain.swift
//  MapTilerSDK
//

package struct GetTerrain: MTValueCommand {
    package func toJS() -> JSString {
        return "JSON.stringify(\(MTBridge.mapObject).getTerrain()) ?? 'null';"
    }
}
