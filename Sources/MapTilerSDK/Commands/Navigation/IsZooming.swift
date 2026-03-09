//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsZooming.swift
//  MapTilerSDK
//

package struct IsZooming: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isZooming();"
    }
}
