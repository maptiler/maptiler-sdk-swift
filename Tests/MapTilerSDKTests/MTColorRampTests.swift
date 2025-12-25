//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTColorRampTests.swift
//  MapTilerSDKTests
//

import XCTest
@testable import MapTilerSDK

final class MTColorRampTests: XCTestCase {
    func testColorEncodingClampsToValidRange() {
        let color = MTRGBAColor(red: 300, green: -5, blue: 127, alpha: -10)

        XCTAssertEqual(color.components, [255, 0, 127, 0])
    }

    func testOptionsEncodeToExpectedJSON() {
        let start = MTColorRampStop(value: 0, color: MTRGBAColor(red: 0, green: 0, blue: 0))
        let end = MTColorRampStop(value: 1, color: MTRGBAColor(red: 255, green: 255, blue: 255))
        let options = MTColorRampOptions(min: 0, max: 1, stops: [start, end])

        XCTAssertEqual(
            options.toJSON(),
            #"{"max":1,"min":0,"stops":[{"color":[0,0,0],"value":0},{"color":[255,255,255],"value":1}]}"#
        )
    }

    func testGetColorCommandBuildsJSONString() {
        let command = GetColorFromColorRamp(
            identifier: "cr1",
            value: 5.0,
            optionsJSON: #"{"smooth":false}"#
        )

        let js = command.toJS()
        XCTAssertTrue(js.contains("window.cr1"))
        XCTAssertTrue(js.contains("getColor(5.0"))
        XCTAssertTrue(js.contains("JSON.stringify"))
    }
}
