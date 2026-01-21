//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddPolygonLayer.swift
//  MapTilerSDK
//

import Foundation

package struct AddPolygonLayer: MTCommand {
    var options: MTPolygonLayerOptions

    package func toJS() -> JSString {
        guard let optionsString = options.toJSON() else {
            return ""
        }

        return """
        (() => {
            \(MTBridge.sdkObject).helpers.addPolygon(\(MTBridge.mapObject), \(optionsString));
            return "";
        })();
        """
    }
}
