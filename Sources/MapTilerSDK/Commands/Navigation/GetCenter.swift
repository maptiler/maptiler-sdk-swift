//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetCenter.swift
//  MapTilerSDK
//

package struct GetCenter: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getCenter();"
    }
}
