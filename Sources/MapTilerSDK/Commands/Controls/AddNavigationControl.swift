//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddNavigationControl.swift
//  MapTilerSDK
//

import Foundation

package struct AddNavigationControl: MTCommand {
    var position: MTMapCorner
    var showCompass: Bool
    var showZoom: Bool
    var visualizePitch: Bool

    package func toJS() -> JSString {
        struct Options: Codable {
            let showCompass: Bool
            let showZoom: Bool
            let visualizePitch: Bool
        }

        let opts = Options(showCompass: showCompass, showZoom: showZoom, visualizePitch: visualizePitch)
        let json = opts.toJSON() ?? "{}"

        return """
        \(MTBridge.mapObject).addControl(\
        new \(MTBridge.sdkObject).MaptilerNavigationControl(\(json)), '\(position.rawValue)');
        """
    }
}
