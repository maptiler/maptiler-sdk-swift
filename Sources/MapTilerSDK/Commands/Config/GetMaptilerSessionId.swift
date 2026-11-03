//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMaptilerSessionId.swift
//  MapTilerSDK
//

package struct GetMaptilerSessionId: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).getMaptilerSessionId();"
    }
}
