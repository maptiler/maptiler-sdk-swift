//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetShouldRenderWorldCopies.swift
//  MapTilerSDK
//

package struct SetShouldRenderWorldCopies: MTCommand {
    var shouldRenderWorldCopies: Bool

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setRenderWorldCopies(\(shouldRenderWorldCopies));"
    }
}
