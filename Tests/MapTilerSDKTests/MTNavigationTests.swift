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
struct MTNavigationTests {
    let zoom = 1.0
    let bearing = 2.0
    let pitch = 3.0
    let roll = 4.0
    let elevation = 5.0
    var centerCoordinate: CLLocationCoordinate2D

    init() {
        centerCoordinate = CLLocationCoordinate2D(latitude: 19.2150224, longitude: 44.7569511)
    }

    @Test func mtMapCameraHelper_isInitialized_Correctly() async throws {
        let mapOptions = MTMapOptions(center: centerCoordinate, bearing: bearing, pitch: pitch, roll: roll, elevation: elevation)

        let cameraHelperWithOptions = MTMapCameraHelper.getCameraWith(mapOptions)
        let cameraHelper = MTMapCameraHelper.cameraLookingAtCenterCoordinate(centerCoordinate, bearing: bearing, pitch: pitch, roll: roll, elevation: elevation)

        #expect(cameraHelper.isEqualToMapCameraHelper(cameraHelperWithOptions))
    }

    @Test func zoomCommands_shouldMatchJS() async throws {
        let zoomInJS = "\(MTBridge.mapObject).zoomIn();"
        let zoomOutJS = "\(MTBridge.mapObject).zoomOut();"
        let setZoomJS = "\(MTBridge.mapObject).setZoom(\(zoom));"
        let getZoomJS = "\(MTBridge.mapObject).getZoom();"
        let setMaxZoomJS = "\(MTBridge.mapObject).setMaxZoom(\(zoom));"
        let setMinZoomJS = "\(MTBridge.mapObject).setMinZoom(\(zoom));"

        #expect(ZoomIn().toJS() == zoomInJS)
        #expect(ZoomOut().toJS() == zoomOutJS)
        #expect(SetZoom(zoom: zoom).toJS() == setZoomJS)
        #expect(GetZoom().toJS() == getZoomJS)
        #expect(SetMaxZoom(maxZoom: zoom).toJS() == setMaxZoomJS)
        #expect(SetMinZoom(minZoom: zoom).toJS() == setMinZoomJS)
    }

    @Test func easeToCommand_shouldMatchJS() async throws {
        let cameraOptions = MTCameraOptions(zoom: zoom, bearing: bearing, pitch: pitch)

        let options = EaseToOptions(center: centerCoordinate, options: cameraOptions, animationOptions: nil)
        let optionsString: JSString = options.toJSON() ?? ""
        let easeToJS = "\(MTBridge.mapObject).easeTo(\(optionsString));"

        #expect(EaseTo(center: centerCoordinate, options: cameraOptions).toJS() == easeToJS)
    }

    @Test func flyToCommand_shouldMatchJS() async throws {
        let flyToOptions = MTFlyToOptions(curve: 1.0, minZoom: 2.0, speed: 3.0, screenSpeed: 4.0, maxDuration: 5.0)

        let options = FlyToOptions(center: centerCoordinate, options: flyToOptions, animationOptions: nil)
        let optionsString: JSString = options.toJSON() ?? ""
        let flyToJS = "\(MTBridge.mapObject).flyTo(\(optionsString));"

        #expect(FlyTo(center: centerCoordinate, options: flyToOptions).toJS() == flyToJS)
    }

    @Test func getPitchCommand_shouldMatchJS() async throws {
        let getPitchJS = "\(MTBridge.mapObject).getPitch();"

        #expect(GetPitch().toJS() == getPitchJS)
    }

    @Test func getMaxPitchCommand_shouldMatchJS() async throws {
        let getMaxPitchJS = "\(MTBridge.mapObject).getMaxPitch();"

        #expect(GetMaxPitch().toJS() == getMaxPitchJS)
    }

    @Test func getMaxZoomCommand_shouldMatchJS() async throws {
        let getMaxZoomJS = "\(MTBridge.mapObject).getMaxZoom();"

        #expect(GetMaxZoom().toJS() == getMaxZoomJS)
    }

    @Test func getMinPitchCommand_shouldMatchJS() async throws {
        let getMinPitchJS = "\(MTBridge.mapObject).getMinPitch();"

        #expect(GetMinPitch().toJS() == getMinPitchJS)
    }

    @Test func getMinZoomCommand_shouldMatchJS() async throws {
        let getMinZoomJS = "\(MTBridge.mapObject).getMinZoom();"

        #expect(GetMinZoom().toJS() == getMinZoomJS)
    }

    @Test func getCenterClampedToGroundCommand_shouldMatchJS() async throws {
        let getCenterClampedToGroundJS = "\(MTBridge.mapObject).getCenterClampedToGround();"

        #expect(GetCenterClampedToGround().toJS() == getCenterClampedToGroundJS)
    }

    @Test func getCenterElevationCommand_shouldMatchJS() async throws {
        let getCenterElevationJS = "\(MTBridge.mapObject).getCenterElevation();"

        #expect(GetCenterElevation().toJS() == getCenterElevationJS)
    }

    @Test func getCameraTargetElevationCommand_shouldMatchJS() async throws {
        let getCameraTargetElevationJS = "\(MTBridge.mapObject).getCameraTargetElevation();"

        #expect(GetCameraTargetElevation().toJS() == getCameraTargetElevationJS)
    }

    @Test func boolValueParsingCoversStringAndNumericValues() async throws {
        let trueString = try MTBridgeReturnType(from: "true")
        let falseString = try MTBridgeReturnType(from: "false")
        let oneString = try MTBridgeReturnType(from: "1")
        let zeroString = try MTBridgeReturnType(from: "0")
        let oneDouble = try MTBridgeReturnType(from: 1.0)
        let zeroDouble = try MTBridgeReturnType(from: 0.0)
        let unexpectedString = try MTBridgeReturnType(from: "maybe")

        #expect(trueString.boolValue == true)
        #expect(falseString.boolValue == false)
        #expect(oneString.boolValue == true)
        #expect(zeroString.boolValue == false)
        #expect(oneDouble.boolValue == true)
        #expect(zeroDouble.boolValue == false)
        #expect(unexpectedString.boolValue == nil)
    }

    @Test func jumpToCommand_shouldMatchJS() async throws {
        let cameraOptions = MTCameraOptions(zoom: zoom, bearing: bearing, pitch: pitch)

        let options = JumpToOptions(center: centerCoordinate, options: cameraOptions)
        let optionsString: JSString = options.toJSON() ?? ""
        let jumpToJS = "\(MTBridge.mapObject).jumpTo(\(optionsString));"

        #expect(JumpTo(center: centerCoordinate, options: cameraOptions).toJS() == jumpToJS)
    }

    @Test func setBearingCommand_shouldMatchJS() async throws {
        let setBearingJS = "\(MTBridge.mapObject).setBearing(\(bearing));"
        
        #expect(SetBearing(bearing: bearing).toJS() == setBearingJS)
    }

    @Test func setCenterCommand_shouldMatchJS() async throws {
        let centerLngLat: LngLat = centerCoordinate.toLngLat()
        let setCenterJS = "\(MTBridge.mapObject).setCenter([\(centerLngLat.lng), \(centerLngLat.lat)]);"

        #expect(SetCenter(center: centerCoordinate).toJS() == setCenterJS)
    }

    @Test func setCenterIsClampedToGroundCommand_shouldMatchJS() async throws {
        let isCenterClampedToGround = true
        let setCenterIsClampedToGroundJS = "\(MTBridge.mapObject).setCenterClampedToGround(\(isCenterClampedToGround));"

        #expect(SetCenterClampedToGround(isCenterClampedToGround: isCenterClampedToGround).toJS() == setCenterIsClampedToGroundJS)
    }

    @Test func setCenterElevationCommand_shouldMatchJS() async throws {
        let setCenterElevationJS = "\(MTBridge.mapObject).setCenterElevation(\(elevation));"

        #expect(SetCenterElevation(elevation: elevation).toJS() == setCenterElevationJS)
    }

    @Test func setMaxPitchCommand_shouldMatchJS() async throws {
        let setMaxPitchJS = "\(MTBridge.mapObject).setMaxPitch(\(pitch));"

        #expect(SetMaxPitch(maxPitch: pitch).toJS() == setMaxPitchJS)
    }

    @Test func setMinPitchCommand_shouldMatchJS() async throws {
        let setMinPitchJS = "\(MTBridge.mapObject).setMinPitch(\(pitch));"

        #expect(SetMinPitch(minPitch: pitch).toJS() == setMinPitchJS)
    }

    @Test func setPaddingCommand_shouldMatchJS() async throws {
        let paddingOptions = MTPaddingOptions(left: 1.0, top: 2.0, right: 3.0, bottom: 4.0)
        let paddingString: JSString = paddingOptions.toJSON() ?? ""

        let setPaddingJS = "\(MTBridge.mapObject).setPadding(\(paddingString));"

        #expect(SetPadding(paddingOptions: paddingOptions).toJS() == setPaddingJS)
    }

    @Test func setPitchCommand_shouldMatchJS() async throws {
        let setPitchJS = "\(MTBridge.mapObject).setPitch(\(pitch));"

        #expect(SetPitch(pitch: pitch).toJS() == setPitchJS)
    }

    @Test func setRollCommand_shouldMatchJS() async throws {
        let setRollJS = "\(MTBridge.mapObject).setRoll(\(roll));"

        #expect(SetRoll(roll: roll).toJS() == setRollJS)
    }

    @Test func fitBoundsCommand_shouldMatchJS() async throws {
        let bounds = MTBounds(
            southWest: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0),
            northEast: CLLocationCoordinate2D(latitude: 30.0, longitude: 40.0)
        )
        let padding = MTFitBoundsPadding.directional(MTPaddingOptions(left: 12.0, top: 8.0, right: 6.0, bottom: 4.0))
        let animationOptions = MTAnimationOptions(
            duration: 2500,
            offset: MTPoint(x: 1.5, y: 2.5),
            shouldAnimate: true,
            isEssential: false,
            easing: .cubic
        )
        let options = MTFitBoundsOptions(
            padding: padding,
            maxZoom: 14.0,
            linear: true,
            bearing: 15.0,
            pitch: 25.0,
            animationOptions: animationOptions
        )

        let boundsString = bounds.toJSON() ?? ""
        var optionsString = options.toJSON() ?? ""
        optionsString = optionsString.replaceEasing()
        let fitBoundsJS = "\(MTBridge.mapObject).fitBounds(\(boundsString), \(optionsString));"

        #expect(FitBounds(bounds: bounds, options: options).toJS() == fitBoundsJS)
    }

    @Test func getBoundsCommand_shouldMatchJS() async throws {
        let getBoundsJS = "JSON.stringify(\(MTBridge.mapObject).getBounds().toArray());"

        #expect(GetBounds().toJS() == getBoundsJS)
    }

    @Test func fitToIpBoundsCommand_shouldMatchJS() async throws {
        let fitToIpBoundsJS = "\(MTBridge.mapObject).fitToIpBounds();"

        #expect(FitToIpBounds().toJS() == fitToIpBoundsJS)
    }

    @Test func centerOnIpPointCommand_shouldMatchJS() async throws {
        let centerOnIpPointJS = "\(MTBridge.mapObject).centerOnIpPoint();"

        #expect(CenterOnIpPoint().toJS() == centerOnIpPointJS)
    }

    @Test func getMaxBoundsCommand_shouldMatchJS() async throws {
        let getMaxBoundsJS = """
(() => {
    const bounds = \(MTBridge.mapObject).getMaxBounds();
    return bounds ? JSON.stringify(bounds.toArray()) : null;
})()
"""

        #expect(GetMaxBounds().toJS() == getMaxBoundsJS)
    }

    @Test func setMaxBoundsCommand_shouldMatchJS() async throws {
        let bounds = MTBounds(
            southWest: CLLocationCoordinate2D(latitude: -10.0, longitude: -20.0),
            northEast: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0)
        )
        let boundsString = bounds.toJSON() ?? ""
        let setMaxBoundsJS = "\(MTBridge.mapObject).setMaxBounds(\(boundsString));"

        #expect(SetMaxBounds(bounds: bounds).toJS() == setMaxBoundsJS)
    }

    @Test func setMaxBoundsCommandWithNil_shouldMatchJS() async throws {
        let setMaxBoundsJS = "\(MTBridge.mapObject).setMaxBounds(null);"

        #expect(SetMaxBounds(bounds: nil).toJS() == setMaxBoundsJS)
    }

    @MainActor
    @Test func centerOnIpPointWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.centerOnIpPoint { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success:
            break
        case .failure(let error):
            Issue.record("Expected centerOnIpPoint wrapper to succeed, but failed with \(error)")
        }

        #expect(executor.lastCommand is CenterOnIpPoint)
    }

    @MainActor
    @Test func getCameraTargetElevationWrapper_shouldDispatchCommand() async throws {
        let expectedElevation = 512.0
        let executor = MockExecutor(result: .double(expectedElevation))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let result = await withCheckedContinuation { continuation in
            mapView.getCameraTargetElevation { outcome in
                continuation.resume(returning: outcome)
            }
        }

        switch result {
        case .success(let elevation):
            #expect(elevation == expectedElevation)
        case .failure(let error):
            Issue.record("Expected getCameraTargetElevation wrapper to succeed, but failed with \(error)")
        }

        #expect(executor.lastCommand is GetCameraTargetElevation)
    }

    @MainActor
    @Test func centerOnIpPointAsyncWrapper_shouldDispatchCommand() async throws {
        let executor = MockExecutor()
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        await mapView.centerOnIpPoint()

        #expect(executor.lastCommand is CenterOnIpPoint)
    }

    @MainActor
    @Test func getCameraTargetElevationAsyncWrapper_shouldDispatchCommand() async throws {
        let expectedElevation = 384.0
        let executor = MockExecutor(result: .double(expectedElevation))
        let mapView = MTMapView(frame: .zero)

        mapView.bridge.executor = executor

        let elevation = await mapView.getCameraTargetElevation()

        #expect(elevation == expectedElevation)
        #expect(executor.lastCommand is GetCameraTargetElevation)
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
