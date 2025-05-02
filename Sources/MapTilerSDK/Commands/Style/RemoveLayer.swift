//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveLayer.swift
//  MapTilerSDK
//

package struct RemoveLayer: MTCommand {
    var layer: MTLayer

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).removeLayer('\(layer.identifier)');"
    }
}
