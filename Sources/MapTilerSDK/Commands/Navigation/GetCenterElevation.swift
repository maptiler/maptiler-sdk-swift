//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetCenterElevation.swift
//  MapTilerSDK
//

package struct GetCenterElevation: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getCenterElevation();"
    }
}
