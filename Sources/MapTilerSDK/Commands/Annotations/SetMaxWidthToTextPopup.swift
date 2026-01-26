//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMaxWidthToTextPopup.swift
//  MapTilerSDK
//

package struct SetMaxWidthToTextPopup: MTCommand {
    var popup: MTTextPopup
    var maxWidth: Double

    package func toJS() -> JSString {
        "window.\(popup.identifier).setMaxWidth(\(maxWidth));"
    }
}
