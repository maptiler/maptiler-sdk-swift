//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddHeatmapLayer.swift
//  MapTilerSDK
//

import Foundation

package struct AddHeatmapLayer: MTCommand {
    var options: MTHeatmapLayerOptions
    var colorRampIdentifier: String?

    package func toJS() -> JSString {
        guard let optionsString = options.toJSON() else {
            return ""
        }

        if let colorRampIdentifier, !colorRampIdentifier.isEmpty {
            return """
            (() => {
                const opts = \(optionsString);
                opts.colorRamp = window.\(colorRampIdentifier) ?? opts.colorRamp;
                \(MTBridge.sdkObject).helpers.addHeatmap(\(MTBridge.mapObject), opts);
                return "";
            })();
            """
        } else {
            return """
            (() => {
                \(MTBridge.sdkObject).helpers.addHeatmap(\(MTBridge.mapObject), \(optionsString));
                return "";
            })();
            """
        }
    }
}
