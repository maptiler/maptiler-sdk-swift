//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsMoving.swift
//  MapTilerSDK
//

package struct IsMoving: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isMoving();"
    }
}
