//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveMarkers.swift
//  MapTilerSDK
//

package struct RemoveMarkers: MTCommand {
    var markers: [MTMarker]

    package func toJS() -> JSString {
        var jsString = ""

        for marker in markers {
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

            let block = """
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

            jsString.append("\n")
            jsString.append(block)
        }

        return jsString
    }
}
