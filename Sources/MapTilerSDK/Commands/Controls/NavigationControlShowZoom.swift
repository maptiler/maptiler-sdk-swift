//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  NavigationControlShowZoom.swift
//  MapTilerSDK
//

import Foundation

package struct NavigationControlShowZoom: MTCommand {
    var showZoom: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).navigationControl.showZoom = \(showZoom);"
    }
}
