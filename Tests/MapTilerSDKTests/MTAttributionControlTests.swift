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
        let command = AddAttributionControl(id: "test-id", position: position, compact: true, customAttribution: ["MapTiler", "OpenStreetMap"])
        
        let expectedJSON = "{\"compact\":true,\"customAttribution\":[\"MapTiler\",\"OpenStreetMap\"]}"
        let expectedJS = """
        window['test-id'] = new \(MTBridge.sdkObject).AttributionControl(\(expectedJSON));
        \(MTBridge.mapObject).addControl(window['test-id'], 'bottom-left');
        """
        
        #expect(command.toJS() == expectedJS)
    }

    @Test func addAttributionControlCommand_withoutOptions_shouldMatchJS() async throws {
        let position = MTMapCorner.bottomRight
        let command = AddAttributionControl(id: "test-id2", position: position, compact: nil, customAttribution: nil)
        
        let expectedJSON = "{}"
        let expectedJS = """
        window['test-id2'] = new \(MTBridge.sdkObject).AttributionControl(\(expectedJSON));
        \(MTBridge.mapObject).addControl(window['test-id2'], 'bottom-right');
        """
        
        #expect(command.toJS() == expectedJS)
    }
}
