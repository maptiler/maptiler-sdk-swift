//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetProjection.swift
//  MapTilerSDK
//

package struct GetProjection: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getProjection();"
    }
}
