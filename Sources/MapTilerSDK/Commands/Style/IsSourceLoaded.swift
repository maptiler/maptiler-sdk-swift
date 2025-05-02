//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsSourceLoaded.swift
//  MapTilerSDK
//

package struct IsSourceLoaded: MTCommand {
    var sourceId: String

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isSourceLoaded('\(sourceId)');"
    }
}
