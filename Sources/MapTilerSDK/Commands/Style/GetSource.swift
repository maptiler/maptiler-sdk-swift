//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetSource.swift
//  MapTilerSDK
//

package struct GetSource: MTValueCommand {
    var id: String

    package func toJS() -> JSString {
        let jsSource = "\(MTBridge.mapObject).getSource('\(id)')"
        return "JSON.stringify(\(jsSource) ? \(jsSource).serialize() : null) ?? 'null';"
    }
}
