//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation

@Suite
struct MTScaleControlTests {

    @Test func addScaleControlCommand_shouldMatchJS() async throws {
        let position = MTMapCorner.bottomLeft
        let command = AddScaleControl(position: position, maxWidth: nil, unit: nil)
        
        let expectedJS = "\(MTBridge.mapObject).addControl(new \(MTBridge.sdkObject).ScaleControl({}), 'bottom-left');"
        #expect(command.toJS() == expectedJS)
    }

    @Test func addScaleControlCommand_withOptions_shouldMatchJS() async throws {
        let position = MTMapCorner.topRight
        let maxWidth = 200
        let unit = MTUnit.imperial
        let command = AddScaleControl(position: position, maxWidth: maxWidth, unit: unit)
        
        let expectedJSON = "{\"maxWidth\":200,\"unit\":\"imperial\"}"
        let expectedJS = "\(MTBridge.mapObject).addControl(new \(MTBridge.sdkObject).ScaleControl(\(expectedJSON)), 'top-right');"
        
        #expect(command.toJS() == expectedJS)
    }
}
