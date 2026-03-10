//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Loaded.swift
//  MapTilerSDK
//

package struct Loaded: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).loaded();"
    }
}
