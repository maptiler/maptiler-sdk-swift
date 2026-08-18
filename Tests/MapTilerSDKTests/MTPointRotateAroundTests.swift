//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointRotateAroundTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointRotateAroundTests {
    @Test
    func testPointRotateAroundCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let angle = 1.5
        let pivot = MTPoint(x: 5, y: 5)
        let command = PointRotateAround(point: point, angle: angle, pivot: pivot)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).rotateAround(1.5, new maptilersdk.Point(5.0, 5.0));"
        #expect(jsString == expectedJS)
    }
}
