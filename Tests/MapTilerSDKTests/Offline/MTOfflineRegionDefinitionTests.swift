//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import Foundation
import CoreLocation
@testable import MapTilerSDK

@Suite("MTOfflineRegionDefinition Compatibility Tests")
struct MTOfflineRegionDefinitionTests {

    @Test("Backward compatibility: Decoding old format with 'bbox'")
    func testDecodeOldFormat() throws {
        let json = """
        {
            "bbox": {
                "minLon": 10,
                "minLat": 20,
                "maxLon": 30,
                "maxLat": 40
            },
            "minZoom": 0,
            "maxZoom": 10,
            "referenceStyle": "streets",
            "pixelRatio": 1.0
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let definition = try decoder.decode(MTOfflineRegionDefinition.self, from: json)

        #expect(definition.bbox.minLon == 10)
        #expect(definition.bbox.maxLat == 40)
        
        if case .boundingBox(let box) = definition.geometry {
            #expect(box.minLon == 10)
        } else {
            Issue.record("Expected boundingBox geometry")
        }
    }

    @Test("Forward compatibility: Encoding new format includes 'bbox'")
    func testEncodeNewFormat() throws {
        let bbox = MTBoundingBox(minLon: 10, minLat: 20, maxLon: 30, maxLat: 40)
        let definition = MTOfflineRegionDefinition(bbox: bbox, minZoom: 0, maxZoom: 10, referenceStyle: .streets)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(definition)
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        #expect(json["bbox"] != nil)
        #expect(json["geometry"] != nil)
        
        let bboxJson = json["bbox"] as! [String: Any]
        #expect(bboxJson["minLon"] as? Double == 10)
    }
    
    @Test("Encoding route geometry still includes bbox")
    func testEncodeRouteFormat() throws {
        let coords = [
            CLLocationCoordinate2D(latitude: 20, longitude: 10),
            CLLocationCoordinate2D(latitude: 40, longitude: 30)
        ]
        let geometry = MTOfflineRegionGeometry.route(coords)
        let definition = MTOfflineRegionDefinition(geometry: geometry, minZoom: 0, maxZoom: 10, referenceStyle: .streets)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(definition)
        
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        #expect(json["bbox"] != nil)
        #expect(json["geometry"] != nil)
        
        let bboxJson = json["bbox"] as! [String: Any]
        #expect(bboxJson["minLon"] as? Double == 10)
        #expect(bboxJson["maxLat"] as? Double == 40)
    }
}
