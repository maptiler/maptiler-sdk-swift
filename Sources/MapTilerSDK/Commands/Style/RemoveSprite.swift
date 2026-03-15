//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveSprite.swift
//  MapTilerSDK
//

import Foundation

package struct RemoveSprite: MTCommand {
    let id: String

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).removeSprite(\(encodedIdentifier()));"
    }

    private func encodedIdentifier() -> String {
        return encode(id)
    }

    private func encode(_ value: String) -> String {
        guard
            let data = try? JSONEncoder().encode(value),
            let string = String(data: data, encoding: .utf8)
        else {
            return "\"\(value)\""
        }

        // Avoid escaping forward slashes to match expected JS output
        return string.replacingOccurrences(of: "\\/", with: "/")
    }
}
