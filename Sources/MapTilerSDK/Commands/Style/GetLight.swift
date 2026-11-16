//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetLight.swift
//  MapTilerSDK
//

package struct GetLight: MTValueCommand {
    package func toJS() -> String {
        return "JSON.stringify(\(MTBridge.mapObject).getLight()) ?? 'null';"
    }
}
