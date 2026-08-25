//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation

@Suite
struct MTTerrainControlTests {

    @Test func addTerrainControlCommand_shouldMatchJS() async throws {
        let position = MTMapCorner.bottomLeft
        let command = AddTerrainControl(position: position)
        
        let expectedJS = "\(MTBridge.mapObject).addControl(new \(MTBridge.sdkObject).MaptilerTerrainControl(), 'bottom-left');"
        #expect(command.toJS() == expectedJS)
    }
}
