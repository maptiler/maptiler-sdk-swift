//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetSky.swift
//  MapTilerSDK
//

package struct GetSky: MTValueCommand {
    package func toJS() -> JSString {
        return "JSON.stringify(\(MTBridge.mapObject).getSky()) ?? 'null';"
    }
}
