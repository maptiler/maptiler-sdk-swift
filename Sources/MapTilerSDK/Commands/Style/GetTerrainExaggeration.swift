//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetTerrainExaggeration.swift
//  MapTilerSDK
//

package struct GetTerrainExaggeration: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getTerrainExaggeration();"
    }
}
