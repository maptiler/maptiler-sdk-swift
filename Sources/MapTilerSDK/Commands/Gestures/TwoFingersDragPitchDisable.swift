//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  TwoFingersDragPitchDisable.swift
//  MapTilerSDK
//

package struct TwoFingersDragPitchDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchPitch.disable();"
    }
}
