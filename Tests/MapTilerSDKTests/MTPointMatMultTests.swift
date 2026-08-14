//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointMatMultTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointMatMultTests {
    @Test
    func testPointMatMultCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let matrix = [1.0, 0.0, 0.0, 1.0]
        let command = PointMatMult(point: point, m: matrix)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).matMult([1.0, 0.0, 0.0, 1.0]);"
        #expect(jsString == expectedJS)
    }
}
