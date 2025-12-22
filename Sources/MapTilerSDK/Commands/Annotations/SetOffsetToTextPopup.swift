//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetOffsetToTextPopup.swift
//  MapTilerSDK
//

package struct SetOffsetToTextPopup: MTCommand {
    var popup: MTTextPopup
    var offset: Double

    package func toJS() -> JSString {
        "\(popup.identifier).setOffset(\(offset));"
    }
}
