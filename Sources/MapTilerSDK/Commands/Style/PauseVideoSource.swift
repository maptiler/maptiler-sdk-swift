//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PauseVideoSource.swift
//  MapTilerSDK
//

import Foundation

package struct PauseVideoSource: MTCommand {
    var source: MTSource

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getSource('\(source.identifier)').pause();"
    }
}
