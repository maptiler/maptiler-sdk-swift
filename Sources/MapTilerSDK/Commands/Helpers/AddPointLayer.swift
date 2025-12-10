//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddPointLayer.swift
//  MapTilerSDK
//

import Foundation

package struct AddPointLayer: MTCommand {
    var options: MTPointLayerOptions

    package func toJS() -> JSString {
        guard let optionsString = options.toJSON() else {
            return ""
        }

        return "\(MTBridge.sdkObject).helpers.addPoint(\(MTBridge.mapObject), \(optionsString));"
    }
}
