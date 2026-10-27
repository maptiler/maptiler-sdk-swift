//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCloseOnMoveToTextPopup.swift
//  MapTilerSDK
//

package struct SetCloseOnMoveToTextPopup: MTCommand {
    var popup: MTTextPopup
    var isEnabled: Bool

    package func toJS() -> JSString {
        """
        var popup = window.\(popup.identifier);
        if (popup) {
            popup.options.closeOnMove = \(isEnabled);
        }
        """
    }
}
