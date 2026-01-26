//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  OpenTextPopup.swift
//  MapTilerSDK
//

package struct OpenTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return "window.\(popup.identifier).addTo(\(MTBridge.mapObject));"
    }
}
