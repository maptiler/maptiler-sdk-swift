//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMaxZoom.swift
//  MapTilerSDK
//

package struct GetMaxZoom: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getMaxZoom();"
    }
}
