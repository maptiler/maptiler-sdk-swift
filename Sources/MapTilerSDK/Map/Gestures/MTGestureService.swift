//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTGestureService.swift
//  MapTilerSDK
//

/// Service responsible for gesture handling and state.
@MainActor
public class MTGestureService {
    /// List of the enabled gestures on the map.
    public private(set) var enabledGestures: [MTGestureType: MTGesture] = [:]

    private var bridge: MTBridge!
    private var eventProcessor: EventProcessor!
    private unowned var mapView: MTMapView!

    private init() {}

    package init(bridge: MTBridge, eventProcessor: EventProcessor, mapView: MTMapView) {
        self.bridge = bridge
        self.eventProcessor = eventProcessor

        enabledGestures[.doubleTapZoomIn] = MTGestureFactory.makeGesture(with: .doubleTapZoomIn, bridge: bridge)
        enabledGestures[.dragPan] = MTGestureFactory.makeGesture(with: .dragPan, bridge: bridge)
        enabledGestures[.twoFingersDragPitch] = MTGestureFactory.makeGesture(with: .twoFingersDragPitch, bridge: bridge)
        enabledGestures[.pinchRotateAndZoom] = MTGestureFactory.makeGesture(with: .pinchRotateAndZoom, bridge: bridge)
    }

    /// Removes the gesture with the provided type from the map.
    /// - Parameters:
    ///   - type: type of gesture to disable.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func disableGesture(with type: MTGestureType, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        if let gesture = enabledGestures[type] {
            Task {
                do {
                    await gesture.disable()
                    enabledGestures.removeValue(forKey: type)
                    completionHandler?(.success(()))
                } catch {
                    if let error = error as? MTError {
                        completionHandler?(.failure(error))
                    } else {
                        completionHandler?(.failure(MTError.bridgeNotLoaded))
                    }
                }
            }

            switch type {
            case .doubleTapZoomIn:
                mapView.options?.setDoubleTapShouldZoom(false)
            case .dragPan:
                mapView.options?.setDragPanIsEnabled(false)
            case .twoFingersDragPitch:
                mapView.options?.setShouldDragToPitch(false)
            case .pinchRotateAndZoom:
                mapView.options?.setShouldPinchToRotateAndZoom(false)
            }
        }
    }

    /// Enables drag to pan gesture.
    /// - Parameters:
    ///   - options: Drag to pan options (optional).
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enableDragPanGesture(
        options: MTDragPanOptions? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        Task {
            do {
                enabledGestures[.dragPan] = MTGestureFactory.makeGesture(with: .dragPan, bridge: bridge)

                guard let dragPanGesture = enabledGestures[.dragPan] as? MTDragPanGesture else {
                    return
                }

                if let options {
                    await dragPanGesture.enable(with: options)
                } else {
                    await dragPanGesture.enable()
                }

                completionHandler?(.success(()))
            } catch {
                if let error = error as? MTError {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }

        mapView.options?.setDragPanIsEnabled(true)
    }

    /// Enables pinch to rotate and zoom gesture.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enablePinchRotateAndZoomGesture(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        Task {
            do {
                enabledGestures[.pinchRotateAndZoom] = MTGestureFactory
                    .makeGesture(with: .pinchRotateAndZoom, bridge: bridge)

                let pinchRotateAndZoomGesture = enabledGestures[.pinchRotateAndZoom] as? MTPinchRotateAndZoomGesture
                guard let pinchRotateAndZoomGesture else {
                    return
                }

                await pinchRotateAndZoomGesture.enable()

                completionHandler?(.success(()))
            } catch {
                if let error = error as? MTError {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }

        mapView.options?.setShouldPinchToRotateAndZoom(true)
    }

    /// Enables two fingers drag pitch gesture.
    ///  - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enableTwoFingerDragPitchGesture(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        Task {
            do {
                enabledGestures[.twoFingersDragPitch] = MTGestureFactory
                    .makeGesture(with: .twoFingersDragPitch, bridge: bridge)

                let twoFingersDragPitchGesture = enabledGestures[.twoFingersDragPitch] as? MTTwoFingersDragPitchGesture
                guard let twoFingersDragPitchGesture else {
                    return
                }

                await twoFingersDragPitchGesture.enable()

                completionHandler?(.success(()))
            } catch {
                if let error = error as? MTError {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }

        mapView.options?.setShouldDragToPitch(true)
    }

    /// Enables double tap zoom in gesture.
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func enableDoubleTapZoomInGesture(completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        Task {
            do {
                enabledGestures[.doubleTapZoomIn] = MTGestureFactory.makeGesture(with: .doubleTapZoomIn, bridge: bridge)

                let doubleTapZoomInGesture = enabledGestures[.doubleTapZoomIn] as? MTDoubleTapZoomInGesture
                guard let doubleTapZoomInGesture else {
                    return
                }

                await doubleTapZoomInGesture.enable()

                completionHandler?(.success(()))
            } catch {
                if let error = error as? MTError {
                    completionHandler?(.failure(error))
                } else {
                    completionHandler?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }

        mapView.options?.setDoubleTapShouldZoom(true)
    }

    /// Sets the double tap sensitivity level (i.e. required time between taps).
    /// - Parameters:
    ///   - completionHandler: A handler block to execute when function finishes.
    /// - Note: Default: 0.4
    public func setDoubleTapSensitivity(_ sensitivity: Double) {
        eventProcessor.setDoubleTapSensitivity(sensitivity)
    }
}

// Concurrency
extension MTGestureService {
    /// Removes the gesture with the provided type from the map.
    /// - Parameters:
    ///   - type: type of gesture to disable.
    public func disableGesture(with type: MTGestureType) async {
        if let gesture = enabledGestures[type] {
            await gesture.disable()

            enabledGestures.removeValue(forKey: type)
        }
    }

    /// Enables drag to pan gesture.
    /// - Parameters:
    ///   - options: Drag to pan options (optional).
    public func enableDragPanGesture(options: MTDragPanOptions? = nil) async {
        enabledGestures[.dragPan] = MTGestureFactory.makeGesture(with: .dragPan, bridge: bridge)

        guard let dragPanGesture = enabledGestures[.dragPan] as? MTDragPanGesture else {
            return
        }

        if let options {
            await dragPanGesture.enable(with: options)
        } else {
            await dragPanGesture.enable()
        }
    }

    /// Enables pinch to rotate and zoom gesture.
    public func enablePinchRotateAndZoomGesture() async {
        enabledGestures[.pinchRotateAndZoom] = MTGestureFactory.makeGesture(with: .pinchRotateAndZoom, bridge: bridge)

        let pinchRotateAndZoomGesture = enabledGestures[.pinchRotateAndZoom] as? MTPinchRotateAndZoomGesture
        guard let pinchRotateAndZoomGesture else {
            return
        }

        await pinchRotateAndZoomGesture.enable()
    }

    /// Enables two fingers drag pitch gesture.
    public func enableTwoFingerDragPitchGesture() async {
        enabledGestures[.twoFingersDragPitch] = MTGestureFactory.makeGesture(with: .twoFingersDragPitch, bridge: bridge)

        let twoFingersDragPitchGesture = enabledGestures[.twoFingersDragPitch] as? MTTwoFingersDragPitchGesture
        guard let twoFingersDragPitchGesture else {
            return
        }

        await twoFingersDragPitchGesture.enable()
    }

    /// Enables double tap zoom in gesture.
    public func enableDoubleTapZoomInGesture() async {
        enabledGestures[.doubleTapZoomIn] = MTGestureFactory.makeGesture(with: .doubleTapZoomIn, bridge: bridge)

        let doubleTapZoomInGesture = enabledGestures[.doubleTapZoomIn] as? MTDoubleTapZoomInGesture
        guard let doubleTapZoomInGesture else {
            return
        }

        await doubleTapZoomInGesture.enable()
    }
}
