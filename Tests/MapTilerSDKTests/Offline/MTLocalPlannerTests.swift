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
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 10, maxZoom: 5, referenceStyle: .base)

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
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 5, referenceStyle: .base)

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
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 5, referenceStyle: .base)
        
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

    @Test("Verify effective limits are respected")
    func testEffectiveLimits() async throws {
        let planner = MTLocalPlanner()
        // A huge bounding box covering the entire world at zoom 0-14 to force a large tile count
        let bbox = MTBoundingBox(minLon: -180, minLat: -85, maxLon: 180, maxLat: 85)
        
        // Use a tiny per-pack limit
        let tinyLimit = 10
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 14, referenceStyle: .base, maxTileCount: tinyLimit)
        
        do {
            _ = try await planner.estimate(for: definition)
            #expect(Bool(false), "Expected exceedsMaximumTileCount error")
        } catch let MTOfflineError.exceedsMaximumTileCount(limit, requested) {
            #expect(limit == tinyLimit)
            #expect(requested > tinyLimit)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }
}
