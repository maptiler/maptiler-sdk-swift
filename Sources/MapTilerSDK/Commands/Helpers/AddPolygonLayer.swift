//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddPolygonLayer.swift
//  MapTilerSDK
//

import Foundation

package struct AddPolygonLayer: MTValueCommand {
    var options: MTPolygonLayerOptions

    package func toJS() -> JSString {
        guard let optionsString = options.toJSON() else {
            return ""
        }

        return """
        (() => {
            const result = \(MTBridge.sdkObject).helpers.addPolygon(\(MTBridge.mapObject), \(optionsString));
            return JSON.stringify(result);
        })();
        """
    }
}
