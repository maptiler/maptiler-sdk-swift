//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation
import CoreGraphics

@Suite
struct MTMapOptionsTests {
    @Test func mapOptionsEncoding_includesLocaleAndMaxCanvasSize() async throws {
        var options = MTMapOptions()
        options.setLocale(["en": "Hello"])
        options.setMaxCanvasSize(CGSize(width: 800, height: 600))

        guard let jsonString = options.toJSON(),
              let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Issue.record("Failed to encode MTMapOptions to JSON.")
            return
        }

        let encodedLocale = json["locale"] as? [String: String]
        #expect(encodedLocale == ["en": "Hello"])

        let encodedMaxCanvasSize = json["maxCanvasSize"] as? [Double]
        #expect(encodedMaxCanvasSize == [800.0, 600.0])
    }
}
