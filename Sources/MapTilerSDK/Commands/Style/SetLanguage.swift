//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetLanguage.swift
//  MapTilerSDK
//

package struct SetLanguage: MTCommand {
    var language: MTLanguage

    package func toJS() -> JSString {
        var languageString: JSString = language.toJSON() ?? ""

        // Replace special language string to match maptilersdk specific language format
        if case .special = language {
            let patternToReplace = #"(\s*)"([^"]*)""#
            languageString = languageString.replacingOccurrences(
                of: patternToReplace,
                with: #"$1$2"#,
                options: .regularExpression
            )
        }

        return "\(MTBridge.mapObject).setLanguage(\(languageString));"
    }
}
