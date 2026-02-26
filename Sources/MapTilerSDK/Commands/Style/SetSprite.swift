//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetSprite.swift
//  MapTilerSDK
//

import Foundation

package struct SetSprite: MTCommand {
    let url: URL

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).setSprite(\(encodedURL()));"
    }

    private func encodedURL() -> String {
        guard
            let data = try? JSONEncoder().encode(url.absoluteString),
            let string = String(data: data, encoding: .utf8)
        else {
            return "\"\(url.absoluteString)\""
        }

        // Avoid escaping forward slashes to match expected JS output
        return string.replacingOccurrences(of: "\\/", with: "/")
    }
}
