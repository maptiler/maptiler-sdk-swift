//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflinePlannerFactoryTests.swift
//  MapTilerSDKTests
//

import Testing
@testable import MapTilerSDK

@Suite("MTOfflinePlannerFactory Tests")
struct MTOfflinePlannerFactoryTests {
    
    @Test("Verify local planner type is returned by default")
    func testDefaultPlannerType() {
        let config = MTOfflineConfiguration()
        config.plannerType = .local // Ensure default state
        
        let planner = MTOfflinePlannerFactory.createPlanner(configuration: config)
        #expect(planner is MTLocalPlanner)
    }
    
    @Test("Verify server planner type can be configured")
    func testServerPlannerType() {
        let config = MTOfflineConfiguration()
        config.plannerType = .server
        
        let planner = MTOfflinePlannerFactory.createPlanner(configuration: config)
        #expect(planner is MTServerPlanner)
    }
}
