//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointMultTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointMultTests {
    @Test
    func testPointMultCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let k = 2.5
        let command = PointMult(point: point, k: k)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).mult(2.5);"
        #expect(jsString == expectedJS)
    }
}
