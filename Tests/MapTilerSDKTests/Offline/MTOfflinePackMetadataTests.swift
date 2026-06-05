//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation
import Testing
@testable import MapTilerSDK

@Suite("Offline Pack Metadata Tests", .serialized)
struct MTOfflinePackMetadataTests {

    @Test("Default values are set correctly on init")
    func testDefaultValues() {
        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1),
            minZoom: 0,
            maxZoom: 5,
            referenceStyle: .base
        )
        let metadata = MTOfflinePackMetadata(region: region)
        
        #expect(metadata.state == .pending)
        #expect(metadata.size == 0)
        // Check if createdAt is close to current time (within 5 seconds for CI stability)
        #expect(abs(metadata.createdAt.timeIntervalSinceNow) < 5.0)
        #expect(metadata.region.minZoom == 0)
    }

    @Test("JSON round-tripping")
    func testJSONRoundTripping() throws {
        let id = UUID()
        // Use a date with zero milliseconds to avoid precision issues during ISO8601 roundtrip
        let timestamp = floor(Date().timeIntervalSince1970)
        let date = Date(timeIntervalSince1970: timestamp)
        
        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: -10, minLat: -10, maxLon: 10, maxLat: 10),
            minZoom: 2,
            maxZoom: 10,
            referenceStyle: .base
        )
        
        let originalMetadata = MTOfflinePackMetadata(
            id: id,
            region: region,
            state: .downloading,
            size: 1024,
            createdAt: date
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(originalMetadata)
        let decodedMetadata = try decoder.decode(MTOfflinePackMetadata.self, from: data)

        #expect(decodedMetadata == originalMetadata)
    }
    
    @Test("ISO8601 date formatting")
    func testISO8601Formatting() throws {
        // Fixed date: 2024-05-12T10:00:00Z
        var components = DateComponents()
        components.year = 2024
        components.month = 5
        components.day = 12
        components.hour = 10
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(abbreviation: "UTC")
        guard let fixedDate = Calendar.current.date(from: components) else {
            Issue.record("Could not create fixed date")
            return
        }
        
        let region = MTOfflineRegionDefinition(
            bbox: MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1),
            minZoom: 0,
            maxZoom: 1,
            referenceStyle: .base
        )
        
        let metadata = MTOfflinePackMetadata(region: region, createdAt: fixedDate)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(metadata)
        let jsonString = String(data: data, encoding: .utf8)!
        
        // The ISO8601 format should at least contain the date and time parts
        #expect(jsonString.contains("2024-05-12T10:00:00"))
    }
}
