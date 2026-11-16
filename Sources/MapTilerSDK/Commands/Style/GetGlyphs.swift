//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetGlyphs.swift
//  MapTilerSDK
//

package struct GetGlyphs: MTValueCommand {
    package func toJS() -> String {
        return "\(MTBridge.mapObject).getGlyphs() ?? 'null';"
    }
}
