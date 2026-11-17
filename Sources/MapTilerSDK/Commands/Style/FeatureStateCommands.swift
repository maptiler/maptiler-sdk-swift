//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  FeatureStateCommands.swift
//  MapTilerSDK
//

import Foundation

package struct SetFeatureState: MTCommand {
    let feature: MTFeatureIdentifier
    let state: [String: MTFeatureStateValue]

    package func toJS() -> JSString {
        let featureJson = feature.toJSON() ?? "{}"
        let stateJson = state.toJSON() ?? "{}"
        return "\(MTBridge.mapObject).setFeatureState(\(featureJson), \(stateJson));"
    }
}

package struct GetFeatureState: MTValueCommand {
    let feature: MTFeatureIdentifier

    package func toJS() -> JSString {
        let featureJson = feature.toJSON() ?? "{}"
        return "JSON.stringify(\(MTBridge.mapObject).getFeatureState(\(featureJson)));"
    }
}

package struct RemoveFeatureState: MTCommand {
    let feature: MTFeatureIdentifier
    let key: String?

    package func toJS() -> JSString {
        let featureJson = feature.toJSON() ?? "{}"
        if let k = key {
            let escapedKey = k.replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            return "\(MTBridge.mapObject).removeFeatureState(\(featureJson), \"\(escapedKey)\");"
        }
        return "\(MTBridge.mapObject).removeFeatureState(\(featureJson));"
    }
}
