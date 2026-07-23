//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  QueryRenderedFeatures.swift
//  MapTilerSDK
//

import Foundation

package struct QueryRenderedFeatures: MTValueCommand {
    var point: CGPoint
    var layers: [String]?
    var filter: String?

    package func toJS() -> JSString {
        var options: [String: Any] = [:]
        if let layers = layers {
            options["layers"] = layers
        }
        if let filter = filter {
            options["filter"] = filter
        }

        let optionsJson: String
        if options.isEmpty {
            optionsJson = "{}"
        } else {
            if let data = try? JSONSerialization.data(withJSONObject: options),
                let jsonString = String(data: data, encoding: .utf8) {
                optionsJson = jsonString
            } else {
                optionsJson = "{}"
            }
        }

        // Use array [x, y] and invariant locale for decimals
        let xStr = String(format: "%.6f", locale: Locale(identifier: "en_US"), point.x)
        let yStr = String(format: "%.6f", locale: Locale(identifier: "en_US"), point.y)

        return "JSON.stringify(\(MTBridge.mapObject).queryRenderedFeatures([\(xStr), \(yStr)], \(optionsJson)));"
    }
}
