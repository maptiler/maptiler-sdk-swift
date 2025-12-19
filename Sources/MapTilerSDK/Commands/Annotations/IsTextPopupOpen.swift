//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsTextPopupOpen.swift
//  MapTilerSDK
//

package struct IsTextPopupOpen: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return "\(popup.identifier).isOpen();"
    }
}
