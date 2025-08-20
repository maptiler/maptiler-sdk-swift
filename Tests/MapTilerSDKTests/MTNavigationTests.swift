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

    @Test func getBearingCommand_shouldMatchJS() async throws {
        let getBearingJS = "\(MTBridge.mapObject).getBearing();"

        #expect(GetBearing().toJS() == getBearingJS)
    }

    @Test func getCenterCommand_shouldMatchJS() async throws {
        let getCenterJS = "\(MTBridge.mapObject).getCenter();"

        #expect(GetCenter().toJS() == getCenterJS)
    }

    @Test func getRollCommand_shouldMatchJS() async throws {
        let getRollJS = "\(MTBridge.mapObject).getRoll();"

        #expect(GetRoll().toJS() == getRollJS)
    }

    @Test func panByCommand_shouldMatchJS() async throws {
        let offset = MTPoint(x: 10.0, y: 20.0)
        let panByJS = "\(MTBridge.mapObject).panBy([\(10.0), \(20.0)]);"

        #expect(PanBy(offset: offset).toJS() == panByJS)
    }

    @Test func panToCommand_shouldMatchJS() async throws {
        let lngLat: LngLat = centerCoordinate.toLngLat()
        let panToJS = "\(MTBridge.mapObject).panTo([\(lngLat.lng), \(lngLat.lat)]);"

        #expect(PanTo(coordinates: centerCoordinate).toJS() == panToJS)
    }

    @Test func projectCommand_shouldMatchJS() async throws {
        let projectJS = "\(MTBridge.mapObject).project([\(centerCoordinate.longitude), \(centerCoordinate.latitude)]);"

        #expect(Project(coordinate: centerCoordinate).toJS() == projectJS)
    }

    // MARK: - MTMapView Navigable API

    final class MockExecutor: MTCommandExecutable, @unchecked Sendable {
        var lastJS: JSString?
        var pitchValue: Double = 31.0
        var bearingValue: Double = 42.0
        var rollValue: Double = 53.0
        var centerValue: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 11, longitude: 22)
        var projectedPoint: (x: Double, y: Double) = (100.0, 200.0)

        func execute(_ command: MTCommand) async throws -> MTBridgeReturnType {
            lastJS = command.toJS()
            switch command {
            case is GetPitch:
                return .double(pitchValue)
            case is GetBearing:
                return .double(bearingValue)
            case is GetRoll:
                return .double(rollValue)
            case is GetCenter:
                return .stringDoubleDict(["lat": centerValue.latitude, "lng": centerValue.longitude])
            case is Project:
                return .stringDoubleDict(["x": projectedPoint.x, "y": projectedPoint.y])
            default:
                return .null
            }
        }
    }

    @MainActor private func makeMapViewWithMock() -> (MTMapView, MockExecutor) {
        let mapView = MTMapView(options: MTMapOptions())
        let mock = MockExecutor()
        mapView.bridge = MTBridge(executor: mock)
        return (mapView, mock)
    }

    @MainActor @Test func mapView_setBearing_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        await mapView.setBearing(bearing)
        #expect(mapView.options?.bearing == bearing)
        #expect(mock.lastJS == SetBearing(bearing: bearing).toJS())
    }

    @MainActor @Test func mapView_setCenter_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        await mapView.setCenter(centerCoordinate)
        #expect(mapView.options?.center == centerCoordinate)
        let lngLat = centerCoordinate.toLngLat()
        #expect(mock.lastJS == SetCenter(center: centerCoordinate).toJS())
        #expect(mock.lastJS == "\(MTBridge.mapObject).setCenter([\(lngLat.lng), \(lngLat.lat)]);")
    }

    @MainActor @Test func mapView_flyTo_updatesCenter_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        let flyOptions = MTFlyToOptions(curve: 1.2, minZoom: 2.3, speed: 3.4, screenSpeed: 4.5, maxDuration: 5.6)
        await mapView.flyTo(centerCoordinate, options: flyOptions, animationOptions: nil)
        #expect(mapView.options?.center == centerCoordinate)
        #expect(mock.lastJS?.contains("flyTo(") == true)
    }

    @MainActor @Test func mapView_easeTo_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        let cameraOptions = MTCameraOptions(zoom: zoom, bearing: bearing, pitch: pitch)
        await mapView.easeTo(centerCoordinate, options: cameraOptions, animationOptions: nil)
        #expect(mapView.options?.center == centerCoordinate)
        #expect(mapView.options?.bearing == bearing)
        #expect(mapView.options?.pitch == pitch)
        #expect(mapView.options?.zoom == zoom)
        #expect(mock.lastJS?.contains("easeTo(") == true)
    }

    @MainActor @Test func mapView_jumpTo_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        let cameraOptions = MTCameraOptions(zoom: zoom, bearing: bearing, pitch: pitch)
        await mapView.jumpTo(centerCoordinate, options: cameraOptions)
        #expect(mapView.options?.center == centerCoordinate)
        #expect(mapView.options?.bearing == bearing)
        #expect(mapView.options?.pitch == pitch)
        #expect(mapView.options?.zoom == zoom)
        #expect(mock.lastJS?.contains("jumpTo(") == true)
    }

    @MainActor @Test func mapView_setPadding_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        let padding = MTPaddingOptions(left: 1, top: 2, right: 3, bottom: 4)
        await mapView.setPadding(padding)
        #expect(mock.lastJS?.contains("setPadding(") == true)
    }

    @MainActor @Test func mapView_setIsCenterClampedToGround_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        await mapView.setIsCenterClampedToGround(true)
        #expect(mapView.options?.isCenterClampedToGround == true)
        #expect(mock.lastJS == SetCenterClampedToGround(isCenterClampedToGround: true).toJS())
    }

    @MainActor @Test func mapView_setCenterElevation_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        await mapView.setCenterElevation(elevation)
        #expect(mapView.options?.elevation == elevation)
        #expect(mock.lastJS == SetCenterElevation(elevation: elevation).toJS())
    }

    @MainActor @Test func mapView_setMaxPitch_updatesOption_whenNonNil() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        try await mapView.setMaxPitch(pitch)
        #expect(mapView.options?.maxPitch == pitch)
        #expect(mock.lastJS == SetMaxPitch(maxPitch: pitch).toJS())
    }

    @MainActor @Test func mapView_setMaxZoom_updatesOption_whenNonNil() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        try await mapView.setMaxZoom(zoom)
        #expect(mapView.options?.maxZoom == zoom)
        #expect(mock.lastJS == SetMaxZoom(maxZoom: zoom).toJS())
    }

    @MainActor @Test func mapView_setMinPitch_updatesOption_whenNonNil() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        try await mapView.setMinPitch(pitch)
        #expect(mapView.options?.minPitch == pitch)
        #expect(mock.lastJS == SetMinPitch(minPitch: pitch).toJS())
    }

    @MainActor @Test func mapView_setMinZoom_updatesOption_whenNonNil() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        try await mapView.setMinZoom(zoom)
        #expect(mapView.options?.minZoom == zoom)
        #expect(mock.lastJS == SetMinZoom(minZoom: zoom).toJS())
    }

    @MainActor @Test func mapView_setPitch_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        await mapView.setPitch(pitch)
        #expect(mapView.options?.pitch == pitch)
        #expect(mock.lastJS == SetPitch(pitch: pitch).toJS())
    }

    @MainActor @Test func mapView_setRoll_updatesOptions_and_callsBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        await mapView.setRoll(roll)
        #expect(mapView.options?.roll == roll)
        #expect(mock.lastJS == SetRoll(roll: roll).toJS())
    }

    @MainActor @Test func mapView_getters_withCompletion_returnValues_fromBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()

        let gotPitch: Double = await mapView.getPitch()
        let gotBearing: Double = await mapView.getBearing()
        let gotRoll: Double = await mapView.getRoll()
        let gotCenter: CLLocationCoordinate2D = await mapView.getCenter()

        #expect(gotPitch == mock.pitchValue)
        #expect(gotBearing == mock.bearingValue)
        #expect(gotRoll == mock.rollValue)
        #expect(gotCenter == mock.centerValue)
    }

    @MainActor @Test func mapView_project_withCompletion_returnsProjectedCoordinate() async throws {
        let (mapView, mock) = makeMapViewWithMock()

        let projected: CLLocationCoordinate2D = await withCheckedContinuation { continuation in
            mapView.project(coordinates: centerCoordinate) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure:
                    continuation.resume(returning: .init())
                }
            }
        }

        #expect(projected.latitude == mock.projectedPoint.x)
        #expect(projected.longitude == mock.projectedPoint.y)
    }

    @MainActor @Test func mapView_panBy_and_panTo_callBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()
        await mapView.panBy(MTPoint(x: 7, y: 8))

        #expect(mock.lastJS == PanBy(offset: MTPoint(x: 7, y: 8)).toJS())

        await mapView.panTo(centerCoordinate)
        #expect(mock.lastJS == PanTo(coordinates: centerCoordinate).toJS())
    }

    @MainActor @Test func mapView_async_getters_returnValues_fromBridge() async throws {
        let (mapView, mock) = makeMapViewWithMock()

        let asyncPitch = await mapView.getPitch()
        let asyncBearing = await mapView.getBearing()
        let asyncRoll = await mapView.getRoll()
        let asyncCenter = await mapView.getCenter()
        let projectedPoint = await mapView.project(coordinates: centerCoordinate)

        #expect(asyncPitch == mock.pitchValue)
        #expect(asyncBearing == mock.bearingValue)
        #expect(asyncRoll == mock.rollValue)
        #expect(asyncCenter == mock.centerValue)
        #expect(projectedPoint.x == mock.projectedPoint.x)
        #expect(projectedPoint.y == mock.projectedPoint.y)
    }
}
