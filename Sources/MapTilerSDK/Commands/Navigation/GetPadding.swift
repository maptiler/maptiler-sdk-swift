//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetPadding.swift
//  MapTilerSDK
//

package struct GetPadding: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getPadding();"
    }
}
