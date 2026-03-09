//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsRotating.swift
//  MapTilerSDK
//

package struct IsRotating: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isRotating();"
    }
}
