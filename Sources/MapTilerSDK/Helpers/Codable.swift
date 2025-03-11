//
//  Codable.swift
//  MapTilerSDK
//

import Foundation

package extension Encodable {
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes

        if let jsonData = try? encoder.encode(self) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }

        MTLogger.log("\(String(describing: self)) encoding failure.", type: .error)
        return nil
    }
}
