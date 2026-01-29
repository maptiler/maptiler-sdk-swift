//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ConvertKML.swift
//  MapTilerSDK
//

import Foundation

package struct ConvertKML: MTValueCommand {
    var kmlString: String

    package func toJS() -> JSString {
        let escaped = kmlString
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")

        return """
        (() => {
            const res = \(MTBridge.sdkObject).kml('\(escaped)');
            return JSON.stringify(res);
        })();
        """
    }
}
