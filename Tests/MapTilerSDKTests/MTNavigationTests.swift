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

    @Test func boolValueParsingCoversStringAndNumericValues() async throws {
        let trueString = try MTBridgeReturnType(from: "true")
        let falseString = try MTBridgeReturnType(from: "false")
        let oneString = try MTBridgeReturnType(from: "1")
        let zeroString = try MTBridgeReturnType(from: "0")
        let unexpectedString = try MTBridgeReturnType(from: "maybe")

        #expect(trueString.boolValue == true)
        #expect(falseString.boolValue == false)
        #expect(oneString.boolValue == true)
        #expect(zeroString.boolValue == false)
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
}
