//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

import Foundation
import CoreLocation

@Suite
struct MTStyleTests {
    @Test func mtFillLayer_shouldEncodeAndDecodeCorrectly() async throws {
        let layer = MTFillLayer(
            identifier: "mock-id",
            sourceIdentifier: "mock-source",
            maxZoom: 2.0,
            minZoom: 20.0,
            sourceLayer: "mock-source-layer"
        )

        layer.color = .blue
        layer.opacity = 0.5
        layer.outlineColor = .red
        layer.shouldBeAntialised = true
        layer.sortKey = 2
        layer.translate = [1.0, 2.0]
        layer.translateAnchor = .map

        let layerJSON = layer.toJSON()
        #expect(layerJSON != nil)

        let decoder = JSONDecoder()
        let decodedLayer = try decoder.decode(MTFillLayer.self, from: Data(layerJSON!.utf8))

        #expect(layer == decodedLayer)
        #expect(layer.color == decodedLayer.color)
        #expect(layer.opacity == decodedLayer.opacity)
        #expect(layer.outlineColor == decodedLayer.outlineColor)
        #expect(layer.shouldBeAntialised == decodedLayer.shouldBeAntialised)
        #expect(layer.sortKey == decodedLayer.sortKey)
        #expect(layer.translate == decodedLayer.translate)
        #expect(layer.translateAnchor == decodedLayer.translateAnchor)
        #expect(layer.visibility == decodedLayer.visibility)
    }

    @Test func mtMapReferenceStyle_containsDefaultVariant() async throws {
        for style in MTMapReferenceStyle.all() {
            #expect(style.getVariants()?.contains(.defaultVariant) ?? false)
        }
    }

    @Test func isGlobeProjectionEnabledCommand_shouldMatchJS() async throws {
        let isGlobeProjectionEnabledJS = "\(MTBridge.mapObject).isGlobeProjection();"

        #expect(IsGlobeProjectionEnabled().toJS() == isGlobeProjectionEnabledJS)
    }
}
