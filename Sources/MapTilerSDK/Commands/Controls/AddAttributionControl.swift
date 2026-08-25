//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddAttributionControl.swift
//  MapTilerSDK
//

import Foundation

package struct AddAttributionControl: MTCommand {
    var position: MTMapCorner
    var compact: Bool?
    var customAttribution: [String]?

    package func toJS() -> JSString {
        struct Options: Codable {
            let compact: Bool?
            let customAttribution: [String]?
        }

        let opts = Options(compact: compact, customAttribution: customAttribution)
        let json = opts.toJSON() ?? "{}"

        return """
        \(MTBridge.mapObject).addControl(\
        new \(MTBridge.sdkObject).AttributionControl(\(json)), '\(position.rawValue)');
        """
    }
}
