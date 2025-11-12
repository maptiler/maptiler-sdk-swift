//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CenterOnIpPoint.swift
//  MapTilerSDK
//

package struct CenterOnIpPoint: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).centerOnIpPoint();"
    }
}
