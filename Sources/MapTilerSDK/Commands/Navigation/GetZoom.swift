//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetZoom.swift
//  MapTilerSDK
//

package struct GetZoom: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getZoom();"
    }
}
