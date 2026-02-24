//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Stop.swift
//  MapTilerSDK
//

package struct Stop: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).stop();"
    }
}
