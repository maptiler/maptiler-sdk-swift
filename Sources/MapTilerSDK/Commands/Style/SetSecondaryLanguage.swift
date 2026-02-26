//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetSecondaryLanguage.swift
//  MapTilerSDK
//

package struct SetSecondaryLanguage: MTCommand {
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

        return "\(MTBridge.mapObject).setSecondaryLanguage(\(languageString));"
    }
}
