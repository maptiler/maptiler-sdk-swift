//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

import Foundation
import CoreLocation
import UIKit

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

    @Test func getProjectionCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).getProjection();"

        #expect(GetProjection().toJS() == expectedJS)
    }

    @Test func getRenderWorldCopiesCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).getRenderWorldCopies();"

        #expect(GetRenderWorldCopies().toJS() == expectedJS)
    }

    @Test func addImageCommand_shouldGenerateExpectedJS() async throws {
        let image = Self.makeTestImage()
        let command = AddImage(name: "poi-icon", image: image, options: nil)

        #expect(command != nil)

        let js = command?.toJS() ?? ""

        #expect(js.contains("\(MTBridge.mapObject).style.addImage(\"poi-icon\","))
        #expect(js.contains("data:image/png;base64,"))
        #expect(js.contains("var imagepoiicon"))
    }

    @Test func addImageCommand_shouldIncludeOptionsJSON() async throws {
        let image = Self.makeTestImage()
        let options = MTStyleImageOptions(
            pixelRatio: 2.0,
            sdf: true,
            stretchX: [MTStyleImageOptions.Stretch(from: 0, to: 10)],
            stretchY: [MTStyleImageOptions.Stretch(from: 5, to: 15)],
            content: MTStyleImageOptions.Content(left: 1, top: 2, right: 3, bottom: 4)
        )

        let command = AddImage(name: "poi", image: image, options: options)

        #expect(command != nil)

        let js = command?.toJS() ?? ""
        let optionsJSON = options.toJSON() ?? ""

        #expect(js.contains(optionsJSON))
    }

    @Test func addSpriteCommand_shouldGenerateExpectedJS() async throws {
        let spriteURL = URL(string: "https://example.com/sprite.png")!
        let command = AddSprite(id: "test-sprite", url: spriteURL)
        let expectedJS = "\(MTBridge.mapObject).addSprite(\"test-sprite\", \"\(spriteURL.absoluteString)\");"

        #expect(command.toJS() == expectedJS)
    }

    @Test func projectionValueParsing_shouldReturnExpectedType() async throws {
        let mercatorReturnType = try MTBridgeReturnType(from: "mercator")
        let globeReturnType = try MTBridgeReturnType(from: "globe")
        let invalidReturnType = try MTBridgeReturnType(from: "unknown")

        #expect(mercatorReturnType.projectionValue == .mercator)
        #expect(globeReturnType.projectionValue == .globe)
        #expect(invalidReturnType.projectionValue == nil)
    }

    @MainActor
    @Test func addImageWrapper_shouldDispatchCommand() async throws {
        let image = Self.makeTestImage()
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.addImage(name: "wrapper-icon", image: image) { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected addImage wrapper to succeed, but failed with \(error)")
        }

        let command = executor.lastCommand as? AddImage

        #expect(command?.name == "wrapper-icon")
        #expect(command?.options == nil)
    }

    @MainActor
    @Test func addSpriteWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        let spriteURL = URL(string: "https://example.com/sprite.json")!

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.addSprite(id: "sprite-wrapper", url: spriteURL) { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected addSprite wrapper to succeed, but failed with \(error)")
        }

        let command = executor.lastCommand as? AddSprite

        #expect(command?.id == "sprite-wrapper")
        #expect(command?.url == spriteURL)
    }

    @MainActor
    @Test func addSpriteAsyncWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        let spriteURL = URL(string: "https://example.com/async-sprite.json")!

        mapView.bridge.executor = executor

        await mapView.addSprite(id: "async-sprite", url: spriteURL)

        let command = executor.lastCommand as? AddSprite

        #expect(command?.id == "async-sprite")
        #expect(command?.url == spriteURL)
    }
}

private extension MTStyleTests {
    static func makeTestImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2))
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: 2, height: 2)))
        }
    }
}

private final class MockExecutor: MTCommandExecutable {
    var lastCommand: (any MTCommand)?
    var result: MTBridgeReturnType

    init(result: MTBridgeReturnType = .null) {
        self.result = result
    }

    func execute(_ command: MTCommand) async throws -> MTBridgeReturnType {
        lastCommand = command
        return result
    }
}
