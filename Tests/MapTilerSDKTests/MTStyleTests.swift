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
        for style in MTMapReferenceStyle.allCases {
            #expect(style.getVariants()?.contains(.defaultVariant) ?? false)
        }
    }

    @Test func testSourceAndLayer_doesExist() async throws {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 19.2150224, longitude: 44.7569511)
        let bearing = 2.0
        let pitch = 3.0
        let roll = 4.0
        let elevation = 5.0

        let mapOptions = MTMapOptions(center: centerCoordinate, bearing: bearing, pitch: pitch, roll: roll, elevation: elevation)
        let mapView = await MTMapView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), options: mapOptions, referenceStyle: .basic, styleVariant: .defaultVariant)
        let style = await MTStyle(for: mapView, with: .basic, and: .defaultVariant)

        let source = MTVectorTileSource(identifier: "mock-source-id", url: URL(string: "https://api.maptiler.com/tiles/v3/tiles.json")!)

        try await style.addSource(source)
        let sourceExists = await style.sourceExists(source)
        #expect(sourceExists)

        let layer = MTFillLayer(identifier: "mock-layer-id", sourceIdentifier: source.identifier)

        try await style.addLayer(layer)
        let layerExists = await style.layerExists(layer)
        #expect(layerExists)

        try await style.removeLayer(layer)
        let layerDoesNotExist = await style.layerExists(layer)
        #expect(!layerDoesNotExist)

        try await style.removeSource(source)
        let sourceDoesNotExist = await style.sourceExists(source)
        #expect(!sourceDoesNotExist)
    }
}
