//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("Offline Validation Tests")
struct MTOfflineValidationTests {

    @Test("Content-Length mismatch should throw sizeMismatch error")
    func testContentLengthMismatch() throws {
        let url = URL(string: "https://api.maptiler.com/style.json")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Length": "1000"]
        )!

        let data = Data(count: 500)

        #expect(throws: MTOfflinePackError.sizeMismatch(expected: 1000, actual: 500)) {
            try response.validateContentLength(dataCount: data.count)
        }
    }

    @Test("Correct Content-Length should not throw")
    func testContentLengthMatch() throws {
        let url = URL(string: "https://api.maptiler.com/style.json")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Length": "500"]
        )!

        let data = Data(count: 500)

        #expect(throws: Never.self) {
            try response.validateContentLength(dataCount: data.count)
        }
    }

    @Test("Missing Content-Length should not throw")
    func testMissingContentLength() throws {
        let url = URL(string: "https://api.maptiler.com/style.json")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [:]
        )!

        let data = Data(count: 500)

        #expect(throws: Never.self) {
            try response.validateContentLength(dataCount: data.count)
        }
    }
}
