//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  TrackTextPopupPointer.swift
//  MapTilerSDK
//

package struct TrackTextPopupPointer: MTCommand {
    var popup: MTTextPopup

    package func toJS() -> JSString {
        "\(popup.identifier).trackPointer();"
    }
}
