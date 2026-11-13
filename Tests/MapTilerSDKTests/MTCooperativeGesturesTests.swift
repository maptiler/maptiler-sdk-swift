//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

@Suite
struct MTCooperativeGesturesTests {
    @Test func testEnableCooperativeGesturesCommand() {
        let command = CooperativeGesturesEnable()
        let expectedJS = "\(MTBridge.mapObject).cooperativeGestures.enable();"
        #expect(command.toJS() == expectedJS)
    }

    @Test func testDisableCooperativeGesturesCommand() {
        let command = CooperativeGesturesDisable()
        let expectedJS = "\(MTBridge.mapObject).cooperativeGestures.disable();"
        #expect(command.toJS() == expectedJS)
    }

    @Test func testIsCooperativeGesturesEnabledCommand() {
        let command = CooperativeGesturesIsEnabled()
        let expectedJS = "\(MTBridge.mapObject).cooperativeGestures.isEnabled();"
        #expect(command.toJS() == expectedJS)
    }
}
