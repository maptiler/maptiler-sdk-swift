//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetPadding.swift
//  MapTilerSDK
//

package struct SetPadding: MTCommand {
    var paddingOptions: MTPaddingOptions?

    package func toJS() -> JSString {
        let paddingString: JSString = paddingOptions.toJSON() ?? ""

        return "\(MTBridge.mapObject).setPadding(\(paddingString));"
    }
}
