//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsStyleLoaded.swift
//  MapTilerSDK
//

package struct IsStyleLoaded: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isStyleLoaded();"
    }
}
