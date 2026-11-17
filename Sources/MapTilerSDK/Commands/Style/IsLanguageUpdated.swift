//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  IsLanguageUpdated.swift
//  MapTilerSDK
//

package struct IsLanguageUpdated: MTValueCommand {
    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).isLanguageUpdated();"
    }
}
