//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsGlobeProjection.swift
//  MapTilerSDK
//

package struct IsGlobeProjection: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isGlobeProjection();"
    }
}
