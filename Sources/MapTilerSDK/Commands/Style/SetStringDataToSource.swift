//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetStringDataToSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetStringDataToSource: MTCommand {
    let emptyReturnValue = ""

    var jsonString: String
    var source: MTSource

    package func toJS() -> JSString {
        // Encode inline JSON as Base64 so we can safely embed and parse on the JS side.
        let encoded = Data(jsonString.utf8).base64EncodedString()
        return "\(MTBridge.mapObject).getSource('" + source.identifier + "').setData(JSON.parse(atob('\(encoded)')));"
    }
}

