//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetHalo.swift
//  MapTilerSDK
//

package struct SetHalo: MTCommand {
    var halo: MTHaloOption

    package func toJS() -> JSString {
        var haloString: JSString = halo.toJSON() ?? ""

        // Unquote object keys (e.g. "scale" -> scale) while preserving value quotes
        // Matches any quoted token immediately followed by a colon
        let keyPattern = #"\"([^\"]+)\"\s*:"#
        haloString = haloString.replacingOccurrences(
            of: keyPattern,
            with: #"$1:"#,
            options: .regularExpression
        )

        return "\(MTBridge.mapObject).setHalo(\(haloString));"
    }
}
