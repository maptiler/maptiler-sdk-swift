//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetMaxParallelImageRequests.swift
//  MapTilerSDK
//

package struct SetMaxParallelImageRequests: MTCommand {
    var maxParallelImageRequests: Int

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject)._setMaxParallelImageRequests(\(maxParallelImageRequests));"
    }
}
