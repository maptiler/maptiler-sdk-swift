//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCoordinatesToPopup.swift
//  MapTilerSDK
//

package struct SetCoordinatesToTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        let coordinates = popup.coordinates.toLngLat()

        return "window.\(popup.identifier).setLngLat([\(coordinates.lng), \(coordinates.lat)]);"
    }
}
