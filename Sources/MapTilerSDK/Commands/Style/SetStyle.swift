//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetStyle.swift
//  MapTilerSDK
//

package struct SetStyle: MTCommand {
    var referenceStyle: MTMapReferenceStyle
    var styleVariant: MTMapStyleVariant?

    package func toJS() -> JSString {
        let referenceStyleName = referenceStyle.getName()

        var styleString = ""

        if referenceStyle.isCustom() {
            styleString = "'\(referenceStyleName)'"
        } else {
            let style = (
                styleVariant != nil && styleVariant != .defaultVariant
            ) ? "\(referenceStyleName).\(styleVariant!.rawValue.uppercased())" : referenceStyleName

            styleString = "\(MTBridge.sdkObject).\(MTBridge.styleObject).\(style)"
        }

        return "\(MTBridge.mapObject).setStyle(\(styleString));"
    }
}
