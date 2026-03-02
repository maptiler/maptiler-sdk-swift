//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetAnchorToTextPopup.swift
//  MapTilerSDK
//

package struct SetAnchorToTextPopup: MTCommand {
    var popup: MTTextPopup
    var anchor: MTAnchor?

    package func toJS() -> JSString {
        if let anchor {
            return """
            window.\(popup.identifier).options.anchor = '\(anchor.rawValue)';
            if (window.\(popup.identifier).isOpen()) {
                window.\(popup.identifier)._update();
            }
            """
        } else {
            return """
            delete window.\(popup.identifier).options.anchor;
            if (window.\(popup.identifier).isOpen()) {
                window.\(popup.identifier)._update();
            }
            """
        }
    }
}
