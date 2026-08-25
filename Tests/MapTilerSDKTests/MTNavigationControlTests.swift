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

    @Test func navigationControlShowCompassCommand_shouldMatchJS() async throws {
        let showCompass = false
        let command = NavigationControlShowCompass(showCompass: showCompass)

        let expectedJS = "\(MTBridge.mapObject).navigationControl.showCompass = false;"
        #expect(command.toJS() == expectedJS)
    }

    @Test func navigationControlShowZoomCommand_shouldMatchJS() async throws {
        let showZoom = false
        let command = NavigationControlShowZoom(showZoom: showZoom)

        let expectedJS = "\(MTBridge.mapObject).navigationControl.showZoom = false;"
        #expect(command.toJS() == expectedJS)
    }

    @Test func navigationControlVisualizePitchCommand_shouldMatchJS() async throws {
        let visualizePitch = true
        let command = NavigationControlVisualizePitch(visualizePitch: visualizePitch)

        let expectedJS = "\(MTBridge.mapObject).navigationControl.visualizePitch = true;"
        #expect(command.toJS() == expectedJS)
    }
}
