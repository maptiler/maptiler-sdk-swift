//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetTelemetry.swift
//  MapTilerSDK
//

package struct SetTelemetry: MTCommand {
    var shouldEnableTelemetry: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.sdkObject).config.telemetry = \(shouldEnableTelemetry);"
    }
}
