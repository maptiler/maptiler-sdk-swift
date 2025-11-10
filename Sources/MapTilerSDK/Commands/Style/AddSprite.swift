//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddSprite.swift
//  MapTilerSDK
//

import Foundation

package struct AddSprite: MTCommand {
    let id: String
    let url: URL

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).addSprite(\(encodedIdentifier()), \(encodedURL()));"
    }

    private func encodedIdentifier() -> String {
        return encode(id)
    }

    private func encodedURL() -> String {
        return encode(url.absoluteString)
    }

    private func encode(_ value: String) -> String {
        guard
            let data = try? JSONEncoder().encode(value),
            let string = String(data: data, encoding: .utf8)
        else {
            return "\"\(value)\""
        }

        return string
    }
}
