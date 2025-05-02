//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveSource.swift
//  MapTilerSDK
//

package struct RemoveSource: MTCommand {
    var source: MTSource

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).removeSource('\(source.identifier)');"
    }
}
