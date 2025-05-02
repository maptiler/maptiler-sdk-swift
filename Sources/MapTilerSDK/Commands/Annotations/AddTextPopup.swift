//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddPopup.swift
//  MapTilerSDK
//

package struct AddTextPopup: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        let coordinates = popup.coordinates.toLngLat()

        return """
            const \(popup.identifier) = new maptilersdk.Popup({ offset: \(popup.offset ?? 0) });

            \(popup.identifier)
            .setLngLat([\(coordinates.lng), \(coordinates.lat)])
            .setText('\(popup.text)')
            .addTo(\(MTBridge.mapObject));
            """
    }
}
