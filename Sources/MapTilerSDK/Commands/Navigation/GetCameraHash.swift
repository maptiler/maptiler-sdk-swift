//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetCameraHash.swift
//  MapTilerSDK
//

package struct GetCameraHash: MTValueCommand {
    package func toJS() -> String {
        return "\(MTBridge.mapObject).getCameraHash() ?? 'null';"
    }
}
