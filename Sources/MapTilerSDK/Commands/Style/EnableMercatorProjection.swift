//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  EnableMercatorProjection.swift
//  MapTilerSDK
//

package struct EnableMercatorProjection: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).enableMercatorProjection();"
    }
}
