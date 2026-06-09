//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTPointAngleTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTPointAngleTests {
    @Test
    func testPointAngleCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let command = PointAngle(point: point)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).angle();"
        #expect(jsString == expectedJS)
    }

    @Test
    func testPointAngleToCommandToJS() async throws {
        let point1 = MTPoint(x: 10, y: 20)
        let point2 = MTPoint(x: 5, y: -5)
        let command = PointAngleTo(point1: point1, point2: point2)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).angleTo(new maptilersdk.Point(5.0, -5.0));"
        #expect(jsString == expectedJS)
    }

    @Test
    func testPointAngleWithCommandToJS() async throws {
        let point1 = MTPoint(x: 10, y: 20)
        let point2 = MTPoint(x: 5, y: -5)
        let command = PointAngleWith(point1: point1, point2: point2)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).angleWith(new maptilersdk.Point(5.0, -5.0));"
        #expect(jsString == expectedJS)
    }

    @Test
    func testPointAngleWithSepCommandToJS() async throws {
        let point = MTPoint(x: 10, y: 20)
        let command = PointAngleWithSep(point: point, x: 5, y: -5)
        let jsString = command.toJS()
        
        let expectedJS = "new maptilersdk.Point(10.0, 20.0).angleWithSep(5.0, -5.0);"
        #expect(jsString == expectedJS)
    }
}
