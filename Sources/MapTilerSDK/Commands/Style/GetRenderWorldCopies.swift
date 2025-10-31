//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetRenderWorldCopies.swift
//  MapTilerSDK
//

package struct GetRenderWorldCopies: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getRenderWorldCopies();"
    }
}
