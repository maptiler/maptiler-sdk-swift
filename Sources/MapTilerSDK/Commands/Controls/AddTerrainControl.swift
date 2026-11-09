//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddTerrainControl.swift
//  MapTilerSDK
//

import Foundation

package struct AddTerrainControl: MTCommand {
    var id: String
    var position: MTMapCorner

    package func toJS() -> JSString {
        return """
        window['\(id)'] = new \(MTBridge.sdkObject).MaptilerTerrainControl();
        \(MTBridge.mapObject).addControl(window['\(id)'], '\(position.rawValue)');
        """
    }
}
