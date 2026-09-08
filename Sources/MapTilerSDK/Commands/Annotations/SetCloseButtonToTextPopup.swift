//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetCloseButtonToTextPopup.swift
//  MapTilerSDK
//

package struct SetCloseButtonToTextPopup: MTCommand {
    var popup: MTTextPopup
    var isVisible: Bool

    package func toJS() -> JSString {
        """
        var popup = window.\(popup.identifier);
        if (popup) {
            popup.options.closeButton = \(isVisible);
            if (\(isVisible)) {
                if (!popup._closeButton && popup._content) {
                    var btn = document.createElement('button');
                    btn.className = 'maplibregl-popup-close-button';
                    btn.type = 'button';
                    btn.innerHTML = '&#215;';
                    btn.setAttribute('aria-label', 'Close popup');
                    btn.addEventListener('click', () => popup.remove());
                    popup._closeButton = btn;
                    popup._content.appendChild(btn);
                } else if (popup._closeButton) {
                    popup._closeButton.style.display = 'block';
                }
            } else if (popup._closeButton) {
                popup._closeButton.style.display = 'none';
            }
        }
        """
    }
}
