//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTConfigTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTConfigTests {

    @Test func getMaptilerSessionIdToJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).getMaptilerSessionId();"
        #expect(GetMaptilerSessionId().toJS() == expectedJS)
    }

    @Test func prewarmToJS() async throws {
        let expectedJS = "\(MTBridge.sdkObject).prewarm();"
        #expect(Prewarm().toJS() == expectedJS)
    }

    @Test func clearPrewarmedResourcesToJS() async throws {
        let expectedJS = "\(MTBridge.sdkObject).clearPrewarmedResources();"
        #expect(ClearPrewarmedResources().toJS() == expectedJS)
    }
}
