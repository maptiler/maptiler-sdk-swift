//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointMultByPointTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointMultByPointTests {
    @Test
    func testPointMultByPointCommandToJS() async throws {
        let point1 = MTPoint(x: 10, y: 20)
        let point2 = MTPoint(x: 2, y: 0.5)
        let command = PointMultByPoint(point1: point1, point2: point2)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).multByPoint(new maptilersdk.Point(2.0, 0.5));"
        #expect(jsString == expectedJS)
    }
}
