//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetSpace.swift
//  MapTilerSDK
//

package struct SetSpace: MTCommand {
    var space: MTSpaceOption

    package func toJS() -> JSString {
        var spaceString: JSString = space.toJSON() ?? ""

        // Unquote object keys (e.g. "preset" -> preset) while preserving value quotes
        // Matches any quoted token immediately followed by a colon
        let keyPattern = #"\"([^\"]+)\"\s*:"#
        spaceString = spaceString.replacingOccurrences(
            of: keyPattern,
            with: #"$1:"#,
            options: .regularExpression
        )

        return "\(MTBridge.mapObject).setSpace(\(spaceString));"
    }
}
