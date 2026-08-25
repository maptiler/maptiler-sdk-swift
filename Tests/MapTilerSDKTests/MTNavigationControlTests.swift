//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation

@Suite
struct MTNavigationControlTests {

    @Test func addNavigationControlCommand_shouldMatchJS() async throws {
        let position = MTMapCorner.bottomLeft
        let showCompass = true
        let showZoom = false
        let visualizePitch = true

        let command = AddNavigationControl(
            position: position,
            showCompass: showCompass,
            showZoom: showZoom,
            visualizePitch: visualizePitch
        )

        let expectedJSON = "{\"showCompass\":true,\"showZoom\":false,\"visualizePitch\":true}"
        let expectedJS = "\(MTBridge.mapObject).addControl(new \(MTBridge.sdkObject).MaptilerNavigationControl(\(expectedJSON)), 'bottom-left');"

        #expect(command.toJS() == expectedJS)
    }
}
