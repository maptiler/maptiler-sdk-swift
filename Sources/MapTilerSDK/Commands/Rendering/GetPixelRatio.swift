//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetPixelRatio.swift
//  MapTilerSDK
//

package struct GetPixelRatio: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getPixelRatio();"
    }
}
