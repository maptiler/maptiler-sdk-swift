//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddHeatmapLayer.swift
//  MapTilerSDK
//

import Foundation

package struct AddHeatmapLayer: MTValueCommand {
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
                if (typeof opts.data === 'string' && opts.data.trim().startsWith('{')) {
                    try { opts.data = JSON.parse(opts.data); } catch (e) {}
                }
                opts.colorRamp = window.\(colorRampIdentifier) ?? opts.colorRamp;
                const result = \(MTBridge.sdkObject).helpers.addHeatmap(\(MTBridge.mapObject), opts);
                return JSON.stringify(result);
            })();
            """
        } else {
            return """
            (() => {
                const opts = \(optionsString);
                if (typeof opts.data === 'string' && opts.data.trim().startsWith('{')) {
                    try { opts.data = JSON.parse(opts.data); } catch (e) {}
                }
                const result = \(MTBridge.sdkObject).helpers.addHeatmap(\(MTBridge.mapObject), opts);
                return JSON.stringify(result);
            })();
            """
        }
    }
}
