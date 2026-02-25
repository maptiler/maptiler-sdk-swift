//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetTerrain.swift
//  MapTilerSDK
//

package struct SetTerrain: MTCommand {
    var sourceId: String?
    var exaggeration: Double?

    package func toJS() -> JSString {
        if let sourceId = sourceId {
            struct Options: Codable {
                let source: String
                let exaggeration: Double?
            }
            let options = Options(source: sourceId, exaggeration: exaggeration)
            let json = options.toJSON() ?? "{}"
            return "\(MTBridge.mapObject).setTerrain(\(json));"
        } else {
            return "\(MTBridge.mapObject).setTerrain();"
        }
    }
}
