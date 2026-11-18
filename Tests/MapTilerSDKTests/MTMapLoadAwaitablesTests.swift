//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapLoadAwaitablesTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

struct MTMapLoadAwaitablesTests {
    @Test
    func testOnLoadAsyncToJS() async throws {
        let command = OnLoadAsync()
        let jsString = command.toJS()
        
        let expectedJS = "await map.onLoadAsync();"
        #expect(jsString == expectedJS)
    }

    @Test
    func testOnReadyAsyncToJS() async throws {
        let command = OnReadyAsync()
        let jsString = command.toJS()
        
        let expectedJS = "await map.onReadyAsync();"
        #expect(jsString == expectedJS)
    }

    @Test
    func testOnLoadWithTerrainAsyncToJS() async throws {
        let command = OnLoadWithTerrainAsync()
        let jsString = command.toJS()
        
        let expectedJS = "await map.onLoadWithTerrainAsync();"
        #expect(jsString == expectedJS)
    }
}
