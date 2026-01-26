//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetTextPopupCoordinates.swift
//  MapTilerSDK
//

package struct GetTextPopupCoordinates: MTValueCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return """
        (() => {
            const p = window.\(popup.identifier).getLngLat();
            return p ? { lat: p.lat, lng: p.lng } : null;
        })();
        """
    }
}
