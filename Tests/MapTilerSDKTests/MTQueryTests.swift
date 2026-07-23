//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation

@Suite
struct MTQueryTests {
    @Test func queryRenderedFeaturesCommand_matchesExpectedJS() async throws {
        let point = CGPoint(x: 100, y: 200)
        let command = QueryRenderedFeatures(point: point, layers: ["layer1"], filter: "[\"==\", \"id\", 1]")
        let jsString = command.toJS()
        
        #expect(jsString.contains("map.queryRenderedFeatures({x: 100.0, y: 200.0}"))
        #expect(jsString.contains("\"layers\":[\"layer1\"]"))
        #expect(jsString.contains("\"filter\":\"[\\\"==\\\", \\\"id\\\", 1]\""))
        #expect(jsString.contains("JSON.stringify"))
    }
}
