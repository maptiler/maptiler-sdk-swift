//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveControl.swift
//  MapTilerSDK
//

import Foundation

package struct RemoveControl: MTCommand {
    var id: String

    package func toJS() -> JSString {
        return """
        if (window['\(id)'] !== undefined) {
            if (\(MTBridge.mapObject).hasControl(window['\(id)'])) {
                \(MTBridge.mapObject).removeControl(window['\(id)']);
            }
            delete window['\(id)'];
        }
        """
    }
}
