//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  TwoFingersDrapPitchEnable.swift
//  MapTilerSDK
//

package struct TwoFingersDragPitchEnable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).touchPitch.enable();"
    }
}
