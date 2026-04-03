//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTLocalPlannerTests.swift
//  MapTilerSDKTests
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("MTLocalPlanner Tests")
struct MTLocalPlannerTests {
    
    @Test("Verify invalid zoom range throws error")
    func testInvalidZoomRange() async throws {
        let planner = MTLocalPlanner()
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 10, maxLat: 10)
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 10, maxZoom: 5, mapId: "basic")
        
        do {
            _ = try await planner.estimate(for: definition)
            #expect(Bool(false), "Expected invalidZoomRange error")
        } catch MTOfflinePackError.invalidZoomRange {
            #expect(true)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
        
        do {
            _ = try await planner.generateManifest(for: definition)
            #expect(Bool(false), "Expected invalidZoomRange error")
        } catch MTOfflinePackError.invalidZoomRange {
            #expect(true)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }
    
    @Test("Verify invalid bounding box coordinates throw error")
    func testInvalidBoundingBox() async throws {
        let planner = MTLocalPlanner()
        // Invalid latitude > 90
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 10, maxLat: 100)
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 5, mapId: "basic")
        
        do {
            _ = try await planner.estimate(for: definition)
            #expect(Bool(false), "Expected invalidBoundingBox error")
        } catch MTOfflinePackError.invalidBoundingBox {
            #expect(true)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
        
        do {
            _ = try await planner.generateManifest(for: definition)
            #expect(Bool(false), "Expected invalidBoundingBox error")
        } catch MTOfflinePackError.invalidBoundingBox {
            #expect(true)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }

    @Test("Verify invalid bounding box min > max throws error")
    func testInvalidBoundingBoxMinMax() async throws {
        let planner = MTLocalPlanner()
        let bbox = MTBoundingBox(minLon: 0, minLat: 10, maxLon: 10, maxLat: 0)
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 5, mapId: "basic")
        
        do {
            _ = try await planner.estimate(for: definition)
            #expect(Bool(false), "Expected invalidBoundingBox error")
        } catch MTOfflinePackError.invalidBoundingBox {
            #expect(true)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
        
        do {
            _ = try await planner.generateManifest(for: definition)
            #expect(Bool(false), "Expected invalidBoundingBox error")
        } catch MTOfflinePackError.invalidBoundingBox {
            #expect(true)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }
}
