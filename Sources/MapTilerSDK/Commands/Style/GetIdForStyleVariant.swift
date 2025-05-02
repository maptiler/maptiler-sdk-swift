//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetIdForStyleVariant.swift
//  MapTilerSDK
//

package struct GetIdForStyleVariant: MTCommand {
    var styleVariant: MTMapStyleVariant

    package func toJS() -> JSString {
        let styleVariant = styleVariant.rawValue.uppercased()

        return "\(MTBridge.sdkObject).\(MTBridge.styleObject).\(styleVariant).getId();"
    }
}
