//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation
import Testing
@testable import MapTilerSDK

@Suite("Feature State Tests")
struct MTFeatureStateTests {
    
    @Test func testMTFeatureStateValueEncoding() throws {
        let state: [String: MTFeatureStateValue] = [
            "hover": .bool(true),
            "count": .number(5),
            "name": .string("test")
        ]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(state)
        let jsonString = String(data: data, encoding: .utf8)!
        
        #expect(jsonString.contains("\"hover\":true"))
        #expect(jsonString.contains("\"count\":5"))
        #expect(jsonString.contains("\"name\":\"test\""))
    }
    
    @Test func testSetFeatureStateCommandJS() throws {
        let feature = MTFeatureIdentifier(source: "my-source", sourceLayer: "my-layer", id: "f1")
        let state: [String: MTFeatureStateValue] = ["hover": true]
        let command = SetFeatureState(feature: feature, state: state)
        let js = command.toJS()
        
        #expect(js.contains("map.setFeatureState("))
        #expect(js.contains("\"source\":\"my-source\""))
        #expect(js.contains("\"sourceLayer\":\"my-layer\""))
        #expect(js.contains("\"id\":\"f1\""))
        #expect(js.contains("\"hover\":true"))
    }
    
    @Test func testGetFeatureStateCommandJS() throws {
        let feature = MTFeatureIdentifier(source: "my-source", id: 123)
        let command = GetFeatureState(feature: feature)
        let js = command.toJS()
        
        #expect(js.contains("JSON.stringify("))
        #expect(js.contains("map.getFeatureState("))
        #expect(js.contains("\"source\":\"my-source\""))
        #expect(js.contains("\"id\":123"))
    }
    
    @Test func testRemoveFeatureStateCommandJS() throws {
        let feature = MTFeatureIdentifier(source: "my-source", id: "f1")
        let command1 = RemoveFeatureState(feature: feature, key: nil)
        let js1 = command1.toJS()
        
        #expect(js1.contains("map.removeFeatureState("))
        #expect(js1.contains("\"source\":\"my-source\""))
        #expect(js1.contains("\"id\":\"f1\""))
        #expect(!js1.hasSuffix(", );"))
        
        let command2 = RemoveFeatureState(feature: feature, key: "hover")
        let js2 = command2.toJS()
        #expect(js2.contains("map.removeFeatureState("))
        #expect(js2.contains("\"hover\""))
    }
}
