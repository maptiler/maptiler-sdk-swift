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

    @Test func defaultUserAgent() async throws {
        // Reset state for test isolation
        await MTConfig.shared.setApplicationIdentifier("")
        
        let ua = MTConfig.customUserAgent
        #expect(ua == "MapTiler-Mobile-SDK-iOS/\(MTConfig.version)")
    }

    @Test func customUserAgent() async throws {
        let appId = "com.example.app"
        await MTConfig.shared.setApplicationIdentifier(appId)
        
        let ua = MTConfig.customUserAgent
        #expect(ua == "\(appId) MapTiler-Mobile-SDK-iOS/\(MTConfig.version)")
        
        // Reset state
        await MTConfig.shared.setApplicationIdentifier("")
    }

    @Test func customUserAgentSanitization() async throws {
        // Test strict allowlist: alphanumeric, period, hyphen, underscore
        // Everything else (spaces, emojis, slashes, control chars) should be stripped
        let maliciousId = "com.example.app\r\nInject: Header\tX🔥 /\\;*"
        await MTConfig.shared.setApplicationIdentifier(maliciousId)
        
        let ua = MTConfig.customUserAgent
        #expect(ua == "com.example.appInjectHeaderX MapTiler-Mobile-SDK-iOS/\(MTConfig.version)")
        
        // Reset state
        await MTConfig.shared.setApplicationIdentifier("")
    }

    @Test func setUseEuEndpointsToJS() async throws {
        #expect(SetUseEuEndpoints(useEuEndpoints: true).toJS() == "\(MTBridge.sdkObject).config.useEuEndpoints = true;")
        #expect(SetUseEuEndpoints(useEuEndpoints: false).toJS() == "\(MTBridge.sdkObject).config.useEuEndpoints = false;")
    }

    @Test func initializeMapPassesUseEuEndpoints() async throws {
        let euCommand = InitializeMap(
            apiKey: "KEY",
            options: nil,
            referenceStyle: .streets,
            styleVariant: nil,
            shouldEnableSessionLogic: true,
            useEuEndpoints: true
        )
        #expect(euCommand.toJS().contains(", true, true);"))

        let defaultCommand = InitializeMap(
            apiKey: "KEY",
            options: nil,
            referenceStyle: .streets,
            styleVariant: nil,
            shouldEnableSessionLogic: true
        )
        #expect(defaultCommand.toJS().contains(", true, false);"))
    }
}
