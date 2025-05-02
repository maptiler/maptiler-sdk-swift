//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  Codable.swift
//  MapTilerSDK
//

import Foundation

package extension Encodable {
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        if let jsonData = try? encoder.encode(self) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }

        MTLogger.log("\(String(describing: self)) encoding failure.", type: .error)
        return nil
    }
}
