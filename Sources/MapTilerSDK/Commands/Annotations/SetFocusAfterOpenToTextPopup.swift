//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetFocusAfterOpenToTextPopup.swift
//  MapTilerSDK
//

package struct SetFocusAfterOpenToTextPopup: MTCommand {
    var popup: MTTextPopup
    var isEnabled: Bool

    package func toJS() -> JSString {
        """
        var popup = window.\(popup.identifier);
        if (popup) {
            popup.options.focusAfterOpen = \(isEnabled);
        }
        """
    }
}
