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
    var position: MTMapCorner

    package func toJS() -> JSString {
        return """
        \(MTBridge.mapObject).addControl(\
        new \(MTBridge.sdkObject).MaptilerTerrainControl(), '\(position.rawValue)');
        """
    }
}
