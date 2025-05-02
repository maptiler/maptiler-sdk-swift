//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsMapLoaded.swift
//  MapTilerSDK
//

package struct IsMapLoaded: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).loaded();"
    }
}
