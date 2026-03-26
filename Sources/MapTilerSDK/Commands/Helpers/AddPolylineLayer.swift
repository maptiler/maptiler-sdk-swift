//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddPolylineLayer.swift
//  MapTilerSDK
//

import Foundation

package struct AddPolylineLayer: MTValueCommand {
    var options: MTPolylineLayerOptions

    package func toJS() -> JSString {
        guard let optionsString = options.toJSON() else {
            return ""
        }

        return """
        (() => {
            const result = \(MTBridge.sdkObject).helpers.addPolyline(\(MTBridge.mapObject), \(optionsString));
            return JSON.stringify(result);
        })();
        """
    }
}
