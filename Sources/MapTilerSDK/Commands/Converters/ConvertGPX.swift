//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ConvertGPX.swift
//  MapTilerSDK
//

import Foundation

package struct ConvertGPX: MTValueCommand {
    var gpxString: String

    package func toJS() -> JSString {
        let escaped = gpxString
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")

        return """
        (() => {
            const res = \(MTBridge.sdkObject).gpx('\(escaped)');
            return JSON.stringify(res);
        })();
        """
    }
}
