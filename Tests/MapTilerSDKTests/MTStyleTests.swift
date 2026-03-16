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
        let expectedJS = """
        (()=>{
          try {
            const spec = \(MTBridge.mapObject).getProjection();
            const isGlobeToken = (s) => {
              if (!s) return false;
              const v = String(s).toLowerCase();
              return v === 'globe' || v === 'vertical-perspective' ||
                v === 'vertical_perspective' || v === 'perspective';
            };
            const scan = (v) => {
              if (typeof v === 'string') return isGlobeToken(v);
              if (Array.isArray(v)) return v.some(scan);
              if (v && typeof v === 'object') return scan(v.type);
              return false;
            };
            return scan(spec) ? 'globe' : 'mercator';
          } catch (_) {
            return 'mercator';
          }
        })()
        """

        #expect(GetProjection().toJS() == expectedJS)
    }

    @Test func getRenderWorldCopiesCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).getRenderWorldCopies();"

        #expect(GetRenderWorldCopies().toJS() == expectedJS)
    }

    @Test func areTilesLoadedCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).areTilesLoaded();"

        #expect(AreTilesLoaded().toJS() == expectedJS)
    }

    @Test func loadedCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).loaded();"

        #expect(Loaded().toJS() == expectedJS)
    }

    @Test func moveLayerCommand_shouldMatchJS() async throws {
        let expectedJS1 = "\(MTBridge.mapObject).moveLayer(\"my-layer\", \"other-layer\");"
        #expect(MoveLayer(id: "my-layer", beforeId: "other-layer").toJS() == expectedJS1)

        let expectedJS2 = "\(MTBridge.mapObject).moveLayer(\"my-layer\");"
        #expect(MoveLayer(id: "my-layer", beforeId: nil).toJS() == expectedJS2)
    }

    @MainActor
    @Test func loadedWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.loaded { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success(let isLoaded):
            #expect(isLoaded)
        case .failure(let error):
            Issue.record("Expected loaded wrapper to succeed, but failed with \(error)")
        }

        #expect(executor.lastCommand is Loaded)
    }

    @MainActor
    @Test func loadedAsyncWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let isLoaded = await mapView.loaded()

        #expect(isLoaded)
        #expect(executor.lastCommand is Loaded)
    }

    @Test func isStyleLoadedCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).isStyleLoaded();"

        #expect(IsStyleLoaded().toJS() == expectedJS)
    }

    @MainActor
    @Test func isStyleLoadedWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.isStyleLoaded { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success(let isLoaded):
            #expect(isLoaded)
        case .failure(let error):
            Issue.record("Expected isStyleLoaded wrapper to succeed, but failed with \(error)")
        }

        #expect(executor.lastCommand is IsStyleLoaded)
    }

    @MainActor
    @Test func isStyleLoadedAsyncWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let isLoaded = await mapView.isStyleLoaded()

        #expect(isLoaded)
        #expect(executor.lastCommand is IsStyleLoaded)
    }

    @Test func isGlobeProjectionCommand_shouldMatchJS() async throws {
        let expectedJS = "\(MTBridge.mapObject).isGlobeProjection();"

        #expect(IsGlobeProjection().toJS() == expectedJS)
    }

    @MainActor
    @Test func isGlobeProjectionWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.isGlobeProjection { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success(let isGlobe):
            #expect(isGlobe)
        case .failure(let error):
            Issue.record("Expected isGlobeProjection wrapper to succeed, but failed with \(error)")
        }

        #expect(executor.lastCommand is IsGlobeProjection)
    }

    @MainActor
    @Test func isGlobeProjectionAsyncWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        let isGlobe = await mapView.isGlobeProjection()

        #expect(isGlobe)
        #expect(executor.lastCommand is IsGlobeProjection)
    }

    @Test func setSkyCommand_shouldMatchJS() async throws {
        let sky = MTSky(
            skyColor: .color(MTColor(hex: "#199EF3")),
            skyHorizonBlend: .number(0.5),
            horizonColor: .color(MTColor(hex: "#ffffff")),
            horizonFogBlend: .number(0.5),
            fogColor: .color(MTColor(hex: "#0000ff")),
            fogGroundBlend: .number(0.5),
            atmosphereBlend: .expression([
                .string("interpolate"),
                .array([.string("linear")]),
                .array([.string("zoom")]),
                .number(0),
                .number(1),
                .number(10),
                .number(1),
                .number(12),
                .number(0)
            ])
        )

        let command = SetSky(sky: sky, options: MTStyleSetterOptions(shouldValidate: false))
        let expectedJS =
            "\(MTBridge.mapObject).setSky({\"atmosphere-blend\":[\"interpolate\",[\"linear\"],[\"zoom\"],0,1,10,1,12,0]," +
            "\"fog-color\":\"#0000ff\",\"fog-ground-blend\":0.5,\"horizon-color\":\"#ffffff\"," +
            "\"horizon-fog-blend\":0.5,\"sky-color\":\"#199EF3\",\"sky-horizon-blend\":0.5}," +
            "{\"shouldValidate\":false});"

        #expect(command.toJS() == expectedJS)
    }

    @MainActor
    @Test func setSkyWrappers_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        let sky = MTSky(skyColor: .color(MTColor(hex: "#FF0000")))
        let options = MTStyleSetterOptions(shouldValidate: false)

        let result = await withCheckedContinuation { continuation in
            mapView.setSky(sky, options: options) { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected setSky wrapper to succeed, but failed with \(error)")
        }

        let command = executor.lastCommand as? SetSky
        
        let expectedColor = try #require(command?.sky.skyColor)
        guard case .color(let color) = expectedColor else {
            Issue.record("Expected .color")
            return
        }
        #expect(color.hex == "#FF0000" || color.hex == "#ff0000")
        #expect(command?.options?.shouldValidate == false)
    }

    @MainActor
    @Test func setSkyAsyncWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        let sky = MTSky(skyColor: .color(MTColor(hex: "#00FF00")))

        await mapView.setSky(sky, options: nil)

        let command = executor.lastCommand as? SetSky
        
        let expectedColor = try #require(command?.sky.skyColor)
        guard case .color(let color) = expectedColor else {
            Issue.record("Expected .color")
            return
        }
        #expect(color.hex == "#00FF00" || color.hex == "#00ff00")
        #expect(command?.options == nil)
    }

    @Test func mtSky_shouldClampNumericValues() async throws {
        let sky = MTSky(
            skyHorizonBlend: .number(2.2),
            horizonFogBlend: .number(-0.5),
            fogGroundBlend: .number(1.5),
            atmosphereBlend: .number(-1)
        )

        let skyJSON = sky.toJSON() ?? ""

        #expect(skyJSON.contains("\"sky-horizon-blend\":1"))
        #expect(skyJSON.contains("\"horizon-fog-blend\":0"))
        #expect(skyJSON.contains("\"fog-ground-blend\":1"))
        #expect(skyJSON.contains("\"atmosphere-blend\":0"))
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

    @Test func updateImageCommand_shouldGenerateExpectedJS() async throws {
        let image = Self.makeTestImage()
        let command = UpdateImage(name: "updated-icon", image: image)

        #expect(command != nil)

        let js = command?.toJS() ?? ""

        #expect(js.contains("\(MTBridge.mapObject).updateImage(\"updated-icon\","))
        #expect(js.contains("data:image/png;base64,"))
        #expect(js.contains("var imageupdatedicon"))
    }

    @Test func addSpriteCommand_shouldGenerateExpectedJS() async throws {
        let spriteURL = URL(string: "https://example.com/sprite.png")!
        let command = AddSprite(id: "test-sprite", url: spriteURL)
        let expectedJS = "\(MTBridge.mapObject).addSprite(\"test-sprite\", \"\(spriteURL.absoluteString)\");"

        #expect(command.toJS() == expectedJS)
    }

    @Test func removeSpriteCommand_shouldGenerateExpectedJS() async throws {
        let command = RemoveSprite(id: "test-sprite")
        let expectedJS = "\(MTBridge.mapObject).removeSprite(\"test-sprite\");"

        #expect(command.toJS() == expectedJS)
    }

    @Test func setSpriteCommand_shouldGenerateExpectedJS() async throws {
        let spriteURL = URL(string: "https://example.com/sprite.png")!
        let command = SetSprite(url: spriteURL)
        let expectedJS = "\(MTBridge.mapObject).setSprite(\"\(spriteURL.absoluteString)\");"

        #expect(command.toJS() == expectedJS)
    }

    @Test func setLayerZoomRangeCommand_shouldGenerateExpectedJS() async throws {
        let command = SetLayerZoomRange(layerId: "my-layer", minzoom: 2.0, maxzoom: 10.5)
        let expectedJS = "\(MTBridge.mapObject).setLayerZoomRange('my-layer', 2.0, 10.5);"

        #expect(command.toJS() == expectedJS)
    }

    @Test func setSecondaryLanguageCommand_shouldGenerateExpectedJS() async throws {
        let command = SetSecondaryLanguage(language: .country(.english))
        let expectedJS = "\(MTBridge.mapObject).setSecondaryLanguage(\"en\");"

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
    @Test func updateImageWrapper_shouldDispatchCommand() async throws {
        let image = Self.makeTestImage()
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.updateImage(name: "updated-wrapper-icon", image: image) { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected updateImage wrapper to succeed, but failed with \(error)")
        }

        let command = executor.lastCommand as? UpdateImage

        #expect(command?.name == "updated-wrapper-icon")
    }

    @MainActor
    @Test func updateImageAsyncWrapper_shouldDispatchCommand() async throws {
        let image = Self.makeTestImage()
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        await mapView.updateImage(name: "updated-async-wrapper", image: image)

        let command = executor.lastCommand as? UpdateImage

        #expect(command?.name == "updated-async-wrapper")
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

    @MainActor
    @Test func removeSpriteWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.removeSprite(id: "sprite-wrapper") { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected removeSprite wrapper to succeed, but failed with \(error)")
        }

        let command = executor.lastCommand as? RemoveSprite

        #expect(command?.id == "sprite-wrapper")
    }

    @MainActor
    @Test func removeSpriteAsyncWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        await mapView.removeSprite(id: "async-sprite")

        let command = executor.lastCommand as? RemoveSprite

        #expect(command?.id == "async-sprite")
    }

    @MainActor
    @Test func setSpriteWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        let spriteURL = URL(string: "https://example.com/sprite.json")!

        mapView.bridge.executor = executor

        let _ = await withCheckedContinuation { continuation in
            mapView.setSprite(spriteURL) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        let command = executor.lastCommand as? SetSprite
        #expect(command?.url == spriteURL)
    }

    @MainActor
    @Test func setSpriteAsyncWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        let spriteURL = URL(string: "https://example.com/sprite.json")!

        mapView.bridge.executor = executor
        await mapView.setSprite(spriteURL)
        
        let command = executor.lastCommand as? SetSprite
        #expect(command?.url == spriteURL)
    }

    @MainActor
    @Test func setSecondaryLanguageWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        let _ = await withCheckedContinuation { continuation in
            mapView.setSecondaryLanguage(.country(.english)) { outcome in
                continuation.resume(returning: outcome)
            }
        }
        
        let command = executor.lastCommand as? SetSecondaryLanguage
        switch command?.language {
        case .country(let country):
            #expect(country == .english)
        default:
            Issue.record("Expected .country(.english)")
        }
    }

    @MainActor
    @Test func setSecondaryLanguageAsyncWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        await mapView.setSecondaryLanguage(.country(.english))
        
        let command = executor.lastCommand as? SetSecondaryLanguage
        switch command?.language {
        case .country(let country):
            #expect(country == .english)
        default:
            Issue.record("Expected .country(.english)")
        }
    }

    @MainActor
    @Test func areTilesLoadedWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.areTilesLoaded { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success(let isLoaded):
            #expect(isLoaded)
        case .failure(let error):
            Issue.record("Expected areTilesLoaded wrapper to succeed, but failed with \(error)")
        }

        #expect(executor.lastCommand is AreTilesLoaded)
    }

    @MainActor
    @Test func areTilesLoadedAsyncWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let isLoaded = await mapView.areTilesLoaded()

        #expect(isLoaded)
        #expect(executor.lastCommand is AreTilesLoaded)
    }

    @Test func setTerrainCommand_shouldMatchJS() async throws {
        let setTerrain = SetTerrain(sourceId: "maptiler-terrain", exaggeration: 1.5)
        let expectedJS = "\(MTBridge.mapObject).setTerrain({\"exaggeration\":1.5,\"source\":\"maptiler-terrain\"});"
        #expect(setTerrain.toJS() == expectedJS)
        
        let setTerrainWithoutExaggeration = SetTerrain(sourceId: "maptiler-terrain", exaggeration: nil)
        let expectedJSWithoutExaggeration = "\(MTBridge.mapObject).setTerrain({\"source\":\"maptiler-terrain\"});"
        #expect(setTerrainWithoutExaggeration.toJS() == expectedJSWithoutExaggeration)

        let clearTerrain = SetTerrain()
        let expectedClearJS = "\(MTBridge.mapObject).setTerrain();"
        #expect(clearTerrain.toJS() == expectedClearJS)
    }

    @Test func setTerrainExaggerationCommand_shouldMatchJS() async throws {
        let commandWithAnimate = SetTerrainExaggeration(exaggeration: 2.0, animate: true)
        let expectedJSWithAnimate = "\(MTBridge.mapObject).setTerrainExaggeration(2.0, true);"
        #expect(commandWithAnimate.toJS() == expectedJSWithAnimate)

        let commandWithoutAnimateOpt = SetTerrainExaggeration(exaggeration: 1.5, animate: nil)
        let expectedJSWithoutAnimateOpt = "\(MTBridge.mapObject).setTerrainExaggeration(1.5);"
        #expect(commandWithoutAnimateOpt.toJS() == expectedJSWithoutAnimateOpt)
    }

    @Test func setTerrainAnimationDurationCommand_shouldMatchJS() async throws {
        let command = SetTerrainAnimationDuration(duration: 500)
        let expectedJS = "\(MTBridge.mapObject).setTerrainAnimationDuration(500.0);"
        #expect(command.toJS() == expectedJS)
    }

    @Test func hasTerrainCommand_shouldMatchJS() async throws {
        let command = HasTerrain()
        let expectedJS = "\(MTBridge.mapObject).hasTerrain();"
        #expect(command.toJS() == expectedJS)
    }

    @MainActor
    @Test func hasTerrainWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.hasTerrain { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success(let hasTerrain):
            #expect(hasTerrain)
        case .failure(let error):
            Issue.record("Expected hasTerrain wrapper to succeed, but failed with \(error)")
        }

        #expect(executor.lastCommand is HasTerrain)
    }

    @MainActor
    @Test func hasTerrainAsyncWrapper_shouldReturnBridgeValue() async throws {
        let executor = MockExecutor(result: .bool(true))
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        let hasTerrain = await mapView.hasTerrain()
        #expect(hasTerrain)
        #expect(executor.lastCommand is HasTerrain)
    }

    @MainActor
    @Test func setTerrainWrappers_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)
        mapView.bridge.executor = executor

        await mapView.setTerrain(sourceId: "maptiler-terrain", exaggeration: 1.5)
        var command = executor.lastCommand as? SetTerrain
        #expect(command?.sourceId == "maptiler-terrain")
        #expect(command?.exaggeration == 1.5)

        await mapView.setTerrainExaggeration(2.0, animate: false)
        var exCommand = executor.lastCommand as? SetTerrainExaggeration
        #expect(exCommand?.exaggeration == 2.0)
        #expect(exCommand?.animate == false)

        await mapView.setTerrainAnimationDuration(1000)
        var durCommand = executor.lastCommand as? SetTerrainAnimationDuration
        #expect(durCommand?.duration == 1000)

        await mapView.setTerrain()
        var clearCommand = executor.lastCommand as? SetTerrain
        #expect(clearCommand?.sourceId == nil)
        #expect(clearCommand?.exaggeration == nil)
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
