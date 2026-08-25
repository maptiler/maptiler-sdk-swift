//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation

@Suite
struct MTAttributionControlTests {

    @Test func addAttributionControlCommand_withOptions_shouldMatchJS() async throws {
        let position = MTMapCorner.bottomLeft
        let command = AddAttributionControl(position: position, compact: true, customAttribution: ["MapTiler", "OpenStreetMap"])
        
        let expectedJSON = "{\"compact\":true,\"customAttribution\":[\"MapTiler\",\"OpenStreetMap\"]}"
        let expectedJS = "\(MTBridge.mapObject).addControl(new \(MTBridge.sdkObject).AttributionControl(\(expectedJSON)), 'bottom-left');"
        
        #expect(command.toJS() == expectedJS)
    }

    @Test func addAttributionControlCommand_withoutOptions_shouldMatchJS() async throws {
        let position = MTMapCorner.bottomRight
        let command = AddAttributionControl(position: position, compact: nil, customAttribution: nil)
        
        let expectedJSON = "{}"
        let expectedJS = "\(MTBridge.mapObject).addControl(new \(MTBridge.sdkObject).AttributionControl(\(expectedJSON)), 'bottom-right');"
        
        #expect(command.toJS() == expectedJS)
    }
}
