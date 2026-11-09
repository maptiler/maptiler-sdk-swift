//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  HasControl.swift
//  MapTilerSDK
//

import Foundation

package struct HasControl: MTValueCommand {
    var id: String

    package func toJS() -> JSString {
        return "(window['\(id)'] !== undefined && \(MTBridge.mapObject).hasControl(window['\(id)']));"
    }
}
