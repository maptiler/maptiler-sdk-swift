//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetTransformRequest.swift
//  MapTilerSDK
//

package struct SetTransformRequest: MTCommand {
    var rules: [MTRequestTransformRule]?

    package func toJS() -> JSString {
        let rulesJson = rules?.toJSON() ?? "null"
        return "\(MTBridge.mapObject).setTransformRequest(createTransformRequest(\(rulesJson)));"
    }
}
