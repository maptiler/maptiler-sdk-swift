//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetTerrainAnimationDuration.swift
//  MapTilerSDK
//

package struct SetTerrainAnimationDuration: MTCommand {
    var duration: Double

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setTerrainAnimationDuration(\(duration));"
    }
}
