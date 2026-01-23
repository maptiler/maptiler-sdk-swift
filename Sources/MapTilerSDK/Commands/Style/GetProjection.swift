//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetProjection.swift
//  MapTilerSDK
//

package struct GetProjection: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getProjection();"
    }
}
