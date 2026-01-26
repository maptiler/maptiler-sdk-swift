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
        return """
        (() => {
            if (window['\(popup.identifier)']) {
                try { window['\(popup.identifier)'].remove(); } catch (e) {}
                delete window['postPopupEvent_\(popup.identifier)'];
                delete window['\(popup.identifier)'];
            }
            return "";
        })();
        """
    }
}
