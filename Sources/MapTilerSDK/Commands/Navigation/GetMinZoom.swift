//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMinZoom.swift
//  MapTilerSDK
//

package struct GetMinZoom: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getMinZoom();"
    }
}
