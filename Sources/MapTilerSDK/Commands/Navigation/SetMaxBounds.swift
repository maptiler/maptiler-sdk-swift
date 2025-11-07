//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMaxBounds.swift
//  MapTilerSDK
//

package struct SetMaxBounds: MTCommand {
    var bounds: MTBounds?

    package func toJS() -> JSString {
        if let boundsString: JSString = bounds?.toJSON() {
            return "\(MTBridge.mapObject).setMaxBounds(\(boundsString));"
        }

        return "\(MTBridge.mapObject).setMaxBounds(null);"
    }
}
