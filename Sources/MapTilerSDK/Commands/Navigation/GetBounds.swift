//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetBounds.swift
//  MapTilerSDK
//

package struct GetBounds: MTValueCommand {
    package func toJS() -> JSString {
        return "JSON.stringify(\(MTBridge.mapObject).getBounds().toArray());"
    }
}
