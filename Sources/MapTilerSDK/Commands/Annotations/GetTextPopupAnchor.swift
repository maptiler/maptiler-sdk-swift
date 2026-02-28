//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetTextPopupAnchor.swift
//  MapTilerSDK
//

package struct GetTextPopupAnchor: MTValueCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        return """
        (() => {
            const popup = window.\(popup.identifier);
            if (!popup) return null;
            if (popup.options.anchor) return popup.options.anchor;
            const match = popup._container?.className.match(/maplibregl-popup-anchor-([a-z-]+)/);
            return match ? match[1] : null;
        })();
        """
    }
}
