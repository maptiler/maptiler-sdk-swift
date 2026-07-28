//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointMagTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointMagTests {
    @Test
    func testPointMagCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let command = PointMag(point: point)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).mag();"
        #expect(jsString == expectedJS)
    }
}
