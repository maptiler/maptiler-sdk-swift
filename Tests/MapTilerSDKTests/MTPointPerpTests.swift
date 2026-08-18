//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointPerpTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointPerpTests {
    @Test
    func testPointPerpCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let command = PointPerp(point: point)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).perp();"
        #expect(jsString == expectedJS)
    }
}
