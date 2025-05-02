//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetDataToSource.swift
//  MapTilerSDK
//

import Foundation

package struct SetDataToSource: MTCommand {
    var data: URL
    var source: MTSource

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').setData('\(data)');"
    }
}
