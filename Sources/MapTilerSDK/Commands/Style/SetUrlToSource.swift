//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetUrlToSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetUrlToSource: MTCommand {
    var url: URL
    var source: MTSource

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').setUrl('\(url)');"
    }
}
