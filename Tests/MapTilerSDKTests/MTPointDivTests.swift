//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointDivTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointDivTests {
    @Test
    func testPointDivCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let k = 2.0
        let command = PointDiv(point: point, k: k)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).div(2.0);"
        #expect(jsString == expectedJS)
    }
}
