//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointRotateTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointRotateTests {
    @Test
    func testPointRotateCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let angle = 1.5
        let command = PointRotate(point: point, angle: angle)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).rotate(1.5);"
        #expect(jsString == expectedJS)
    }
}
