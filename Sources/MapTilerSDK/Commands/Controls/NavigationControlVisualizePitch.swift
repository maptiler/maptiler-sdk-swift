//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  NavigationControlVisualizePitch.swift
//  MapTilerSDK
//

import Foundation

package struct NavigationControlVisualizePitch: MTCommand {
    var visualizePitch: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).navigationControl.visualizePitch = \(visualizePitch);"
    }
}
