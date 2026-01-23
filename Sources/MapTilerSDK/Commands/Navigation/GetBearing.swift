//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetBearing.swift
//  MapTilerSDK
//

package struct GetBearing: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getBearing();"
    }
}
