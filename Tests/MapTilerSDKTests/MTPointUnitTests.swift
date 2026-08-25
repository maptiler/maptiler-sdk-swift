//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointUnitTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointUnitTests {
    @Test
    func testPointUnitCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let command = PointUnit(point: point)
        let jsString = command.toJS()

        let expectedJS = "new maptilersdk.Point(10.0, 20.0).unit();"
        #expect(jsString == expectedJS)
    }
}
