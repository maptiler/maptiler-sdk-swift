//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetSubpixelPositioningToTextPopup.swift
//  MapTilerSDK
//

package struct SetSubpixelPositioningToTextPopup: MTCommand {
    var popup: MTTextPopup
    var isEnabled: Bool

    package func toJS() -> JSString {
        "\(popup.identifier).setSubpixelPositioning(\(isEnabled));"
    }
}
