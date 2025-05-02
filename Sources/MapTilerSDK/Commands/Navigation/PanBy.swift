//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PanBy.swift
//  MapTilerSDK
//

package struct PanBy: MTCommand {
    var offset: MTPoint

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).panBy([\(offset.x), \(offset.y)]);"
    }
}
