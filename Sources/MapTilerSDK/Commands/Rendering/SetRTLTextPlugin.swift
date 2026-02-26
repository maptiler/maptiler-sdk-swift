//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetRTLTextPlugin.swift
//  MapTilerSDK
//

package struct SetRTLTextPlugin: MTCommand {
    var pluginURL: String
    var deferred: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setRTLTextPlugin('\(pluginURL)', \(deferred));"
    }
}
