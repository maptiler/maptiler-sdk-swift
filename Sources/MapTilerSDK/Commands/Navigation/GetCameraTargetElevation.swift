//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetCameraTargetElevation.swift
//  MapTilerSDK
//

package struct GetCameraTargetElevation: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getCameraTargetElevation();"
    }
}
