//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

import Foundation

@Suite
struct MTRenderingTests {
    @Test func pixelRatioCommands_shouldMatchJS() async throws {
        let expectedSetPixelRatioJS = "\(MTBridge.mapObject).setPixelRatio(2.0);"
        let expectedGetPixelRatioJS = "\(MTBridge.mapObject).getPixelRatio();"

        #expect(SetPixelRatio(pixelRatio: 2.0).toJS() == expectedSetPixelRatioJS)
        #expect(GetPixelRatio().toJS() == expectedGetPixelRatioJS)
    }

    @Test func triggerRepaintCommand_shouldMatchJS() async throws {
        let expectedTriggerRepaintJS = "\(MTBridge.mapObject).triggerRepaint();"

        #expect(TriggerRepaint().toJS() == expectedTriggerRepaintJS)
    }

    @Test func mapOptionsEncoding_includesPixelRatio() async throws {
        let pixelRatio = 1.5
        let options = MTMapOptions(pixelRatio: pixelRatio)

        guard let jsonString = options.toJSON(),
              let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Issue.record("Failed to encode MTMapOptions to JSON.")
            return
        }

        let encodedPixelRatio = json["pixelRatio"] as? Double
        #expect(encodedPixelRatio == pixelRatio)
    }
}
