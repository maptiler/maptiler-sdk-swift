//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveTextPopup.swift
//  MapTilerSDK
//

package struct RemoveTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return "\(popup.identifier).remove();"
    }
}
