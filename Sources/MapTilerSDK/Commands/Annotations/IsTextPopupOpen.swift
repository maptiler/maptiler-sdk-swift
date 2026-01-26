//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsTextPopupOpen.swift
//  MapTilerSDK
//

package struct IsTextPopupOpen: MTValueCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return "window.\(popup.identifier).isOpen();"
    }
}
