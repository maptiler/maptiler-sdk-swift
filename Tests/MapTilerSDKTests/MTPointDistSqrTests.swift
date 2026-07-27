//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointDistSqrTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointDistSqrTests {
    @Test
    func testPointDistSqrCommandToJS() async throws {
        let point1 = MTPoint(x: 10, y: 20)
        let point2 = MTPoint(x: 5, y: -5)
        let command = PointDistSqr(point1: point1, point2: point2)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).distSqr(new maptilersdk.Point(5.0, -5.0));"
        #expect(jsString == expectedJS)
    }
}
