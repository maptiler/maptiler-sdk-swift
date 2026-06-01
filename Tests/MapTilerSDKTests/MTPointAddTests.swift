//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointAddTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointAddTests {
    @Test
    func testPointAddCommandToJS() async throws {
        let point1 = MTPoint(x: 10, y: 20)
        let point2 = MTPoint(x: 5, y: -5)
        let command = PointAdd(point1: point1, point2: point2)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).add(new maptilersdk.Point(5.0, -5.0));"
        #expect(jsString == expectedJS)
    }
}
