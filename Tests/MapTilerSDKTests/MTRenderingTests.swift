//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

import Foundation

@Suite
struct MTRenderingTests {
    @Test func pixelRatioCommands_shouldMatchJS() async throws {
        let expectedSetPixelRatioJS = "\(MTBridge.mapObject).setPixelRatio(2.0);"
        let expectedGetPixelRatioJS = "\(MTBridge.mapObject).getPixelRatio();"

        #expect(SetPixelRatio(pixelRatio: 2.0).toJS() == expectedSetPixelRatioJS)
        #expect(GetPixelRatio().toJS() == expectedGetPixelRatioJS)
    }

    @Test func triggerRepaintCommand_shouldMatchJS() async throws {
        let expectedTriggerRepaintJS = "\(MTBridge.mapObject).triggerRepaint();"

        #expect(TriggerRepaint().toJS() == expectedTriggerRepaintJS)
    }

    @Test func setShowTileBoundariesCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).showTileBoundaries = true;"
        #expect(SetShowTileBoundaries(show: true).toJS() == expectedJS)
        
        let expectedFalseJS = "\(MTBridge.mapObject).showTileBoundaries = false;"
        #expect(SetShowTileBoundaries(show: false).toJS() == expectedFalseJS)
    }

    @Test func setShowPaddingCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).showPadding = true;"
        #expect(SetShowPadding(show: true).toJS() == expectedJS)
        
        let expectedFalseJS = "\(MTBridge.mapObject).showPadding = false;"
        #expect(SetShowPadding(show: false).toJS() == expectedFalseJS)
    }

    @Test func setShowOverdrawInspectorCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).showOverdrawInspector = true;"
        #expect(SetShowOverdrawInspector(show: true).toJS() == expectedJS)
        
        let expectedFalseJS = "\(MTBridge.mapObject).showOverdrawInspector = false;"
        #expect(SetShowOverdrawInspector(show: false).toJS() == expectedFalseJS)
    }

    @Test func setShowCollisionBoxesCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).showCollisionBoxes = true;"
        #expect(SetShowCollisionBoxes(show: true).toJS() == expectedJS)
        
        let expectedFalseJS = "\(MTBridge.mapObject).showCollisionBoxes = false;"
        #expect(SetShowCollisionBoxes(show: false).toJS() == expectedFalseJS)
    }

    @Test func setMaxParallelImageRequestsCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject)._setMaxParallelImageRequests(10);"
        #expect(SetMaxParallelImageRequests(maxParallelImageRequests: 10).toJS() == expectedJS)
    }

    @Test func setRTLTextPluginCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).setRTLTextPlugin('https://example.com/plugin.js', true);"
        #expect(SetRTLTextPlugin(pluginURL: "https://example.com/plugin.js", deferred: true).toJS() == expectedJS)

        let expectedFalseJS = "\(MTBridge.mapObject).setRTLTextPlugin('https://example.com/plugin.js', false);"
        #expect(SetRTLTextPlugin(pluginURL: "https://example.com/plugin.js", deferred: false).toJS() == expectedFalseJS)
    }

    @Test func mapOptionsEncoding_includesPixelRatio() async throws {
        let pixelRatio = 1.5
        let options = MTMapOptions(pixelRatio: pixelRatio)

        guard let jsonString = options.toJSON(),
              let data = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Issue.record("Failed to encode MTMapOptions to JSON.")
            return
        }

        let encodedPixelRatio = json["pixelRatio"] as? Double
        #expect(encodedPixelRatio == pixelRatio)
    }
}
