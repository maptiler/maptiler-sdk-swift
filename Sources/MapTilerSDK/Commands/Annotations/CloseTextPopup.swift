//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CloseTextPopup.swift
//  MapTilerSDK
//

package struct CloseTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return "window.\(popup.identifier).remove();"
    }
}
