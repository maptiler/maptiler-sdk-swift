//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  EnableGlobeProjection.swift
//  MapTilerSDK
//

package struct EnableGlobeProjection: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).enableGlobeProjection();"
    }
}
