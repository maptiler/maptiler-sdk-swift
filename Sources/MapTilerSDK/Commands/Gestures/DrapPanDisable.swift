//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  DrapPanDisable.swift
//  MapTilerSDK
//

package struct DragPanDisable: MTCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).dragPan.disable();"
    }
}
