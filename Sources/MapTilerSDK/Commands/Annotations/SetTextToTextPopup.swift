//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetTextToTextPopup.swift
//  MapTilerSDK
//

package struct SetTextToTextPopup: MTCommand {
    var popup: MTTextPopup
    var text: String

    package func toJS() -> JSString {
        let escapedText = text.replacingOccurrences(of: "'", with: "\\'")
        return "window.\(popup.identifier).setText('\(escapedText)');"
    }
}
