//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetVerticalFieldOfView.swift
//  MapTilerSDK
//

package struct GetVerticalFieldOfView: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getVerticalFieldOfView();"
    }
}
