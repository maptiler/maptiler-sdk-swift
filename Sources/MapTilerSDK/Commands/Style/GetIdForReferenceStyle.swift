//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetIdForReferenceStyle.swift
//  MapTilerSDK
//

package struct GetIdForReferenceStyle: MTCommand {
    var referenceStyle: MTMapReferenceStyle

    package func toJS() -> JSString {
        let referenceStyle = referenceStyle.getName()

        return "\(MTBridge.sdkObject).\(MTBridge.styleObject).\(referenceStyle).getId();"
    }
}
