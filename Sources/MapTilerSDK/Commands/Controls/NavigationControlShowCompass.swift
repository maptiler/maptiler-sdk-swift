//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  NavigationControlShowCompass.swift
//  MapTilerSDK
//

import Foundation

package struct NavigationControlShowCompass: MTCommand {
    var showCompass: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).navigationControl.showCompass = \(showCompass);"
    }
}
