//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddScaleControl.swift
//  MapTilerSDK
//

import Foundation

package struct AddScaleControl: MTCommand {
    var id: String
    var position: MTMapCorner
    var maxWidth: Int?
    var unit: MTUnit?

    package func toJS() -> JSString {
        struct Options: Codable {
            let maxWidth: Int?
            let unit: String?
        }

        let opts = Options(maxWidth: maxWidth, unit: unit?.rawValue)
        let json = opts.toJSON() ?? "{}"

        return """
        window['\(id)'] = new \(MTBridge.sdkObject).ScaleControl(\(json));
        \(MTBridge.mapObject).addControl(window['\(id)'], '\(position.rawValue)');
        """
    }
}
