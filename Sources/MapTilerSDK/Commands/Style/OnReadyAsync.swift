//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  OnReadyAsync.swift
//  MapTilerSDK
//

package struct OnReadyAsync: MTCommand {
    package func toJS() -> JSString {
        return "await \(MTBridge.mapObject).onReadyAsync();"
    }
}
