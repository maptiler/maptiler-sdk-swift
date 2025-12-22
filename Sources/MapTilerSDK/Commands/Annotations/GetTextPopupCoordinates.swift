//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetTextPopupCoordinates.swift
//  MapTilerSDK
//

package struct GetTextPopupCoordinates: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return "\(popup.identifier).getLngLat();"
    }
}
