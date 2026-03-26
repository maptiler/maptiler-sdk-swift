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
        (async () => {
            const opts = \(optionsString);
            if (typeof opts.data === 'string' && opts.data.trim().startsWith('{')) {
                try { opts.data = JSON.parse(opts.data); } catch (e) {}
            }
            const result = await \(MTBridge.sdkObject).helpers.addPolyline(\(MTBridge.mapObject), opts);
            return JSON.stringify(result);
        })();
        """
    }
}
