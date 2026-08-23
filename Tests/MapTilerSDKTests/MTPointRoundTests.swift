//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointRoundTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointRoundTests {
    @Test
    func testPointRoundCommandToJS() async throws {
        let point = MTPoint(x: 10.5, y: 20.3)
        let command = PointRound(point: point)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.5, 20.3).round();"
        #expect(jsString == expectedJS)
    }
}
