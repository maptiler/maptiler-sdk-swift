//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveMarker.swift
//  MapTilerSDK
//

package struct RemoveMarker: MTCommand {
    var marker: MTMarker

    package func toJS() -> JSString {
        var popupCleanup = ""

        if let popup = marker.popup {
            popupCleanup = """
                if (window['\(popup.identifier)']) {
                    try { window['\(popup.identifier)'].remove(); } catch (e) {}
                    delete window['postPopupEvent_\(popup.identifier)'];
                    delete window['\(popup.identifier)'];
                }
            """
        }

        return """
        (() => {
            if (window['\(marker.identifier)']) {
                try { window['\(marker.identifier)'].remove(); } catch (e) {}
                delete window['postDragEvent_\(marker.identifier)'];
                delete window['\(marker.identifier)'];
            }
            \(popupCleanup)
            return "";
        })();
        """
    }
}
