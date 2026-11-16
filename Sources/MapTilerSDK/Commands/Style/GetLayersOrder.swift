//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetLayersOrder.swift
//  MapTilerSDK
//

package struct GetLayersOrder: MTValueCommand {
    package func toJS() -> String {
        return "JSON.stringify(\(MTBridge.mapObject).getLayersOrder()) ?? 'null';"
    }
}
