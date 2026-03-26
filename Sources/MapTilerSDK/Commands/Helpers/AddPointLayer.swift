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
    var colorRampIdentifier: String?

    package func toJS() -> JSString {
        guard let optionsString = options.toJSON() else {
            return ""
        }

        if let colorRampIdentifier, !colorRampIdentifier.isEmpty {
            return """
            (() => {
                const opts = \(optionsString);
                opts.pointColor = window.\(colorRampIdentifier) ?? opts.pointColor;
                const result = \(MTBridge.sdkObject).helpers.addPoint(\(MTBridge.mapObject), opts);
                return JSON.stringify(result);
            })();
            """
        } else {
            return """
            (() => {
                const result = \(MTBridge.sdkObject).helpers.addPoint(\(MTBridge.mapObject), \(optionsString));
                return JSON.stringify(result);
            })();
            """
        }
    }
}
