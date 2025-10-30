//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView.swift
//  MapTilerSDK
//

import UIKit
import WebKit
import CoreLocation

package class MTWeakContentDelegate {
    var id: String
    weak var delegate: (any MTMapViewContentDelegate)?

    init(delegate: MTMapViewContentDelegate? = nil) {
        self.id = UUID().uuidString
        self.delegate = delegate
    }
}

/// Delegate responsible for map event propagation
@MainActor
public protocol MTMapViewDelegate: AnyObject {
    /// Triggers when map is fully initialized.
    func mapViewDidInitialize(_ mapView: MTMapView)

    /// Triggers when event ocurrs.
    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?)

    /// Triggers when location is updated.
    func mapView(_ mapView: MTMapView, didUpdateLocation location: CLLocation)
}

@MainActor
package protocol MTMapViewContentDelegate: AnyObject {
    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?)
}

extension MTMapViewDelegate {
    public func mapView(_ mapView: MTMapView, didUpdateLocation location: CLLocation) {
        MTLogger.log("MTLocationManager didUpdateLocation", type: .info)
    }
}

/// Object representing the map on the screen.
///
/// Exposes methods and properties that enable changes to the map,
/// and fires events that can be interacted with.
open class MTMapView: UIView, Sendable {
    /// Proxy style object of the map.
    public private(set) var style: MTStyle?

    public private(set) var locationManager: MTLocationManager? {
        didSet {
            locationManager?.delegate = self
        }
    }

    private var referenceStyleProxy: MTMapReferenceStyle = .streets
    private var styleVariantProxy: MTMapStyleVariant?

    /// Current options of the map object.
    public var options: MTMapOptions? = MTMapOptions()

    /// Service responsible for gestures handling
    public var gestureService: MTGestureService!

    /// Delegate object responsible for event propagation
    public weak var delegate: MTMapViewDelegate?

    package var contentDelegates: [String: MTWeakContentDelegate] = [:]

    /// Boolean indicating whether map is initialized,
    public private(set) var isInitialized: Bool = false

    /// Triggers when map initializes for the first time.
    public var didInitialize: (() -> Void)?

    package var bridge: MTBridge!

    package var eventProcessor: EventProcessor!

    private var webViewExecutor: WebViewExecutor!

    /// Initializes the map with the frame.
    override public init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    /// Initializes the map with the coder.
    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    /// Initializes the map with the frame, options and style.
    convenience public init(
        frame: CGRect,
        options: MTMapOptions,
        referenceStyle: MTMapReferenceStyle,
        styleVariant: MTMapStyleVariant? = nil
    ) {
        self.init(frame: frame)

        self.options = options

        self.referenceStyleProxy = referenceStyle
        self.styleVariantProxy = styleVariant

        commonInit()
    }

    /// Initializes the map with the options.
    convenience public init(options: MTMapOptions?) {
        self.init()

        self.options = options

        commonInit()
    }

    /// Initializes location tracking manager.
    ///
    /// In order to track user location you have to initialize the MLLocationManager,
    /// add necessary Privacy Location messages to Info.plist, subscribe to MTLocationManagerDelegate
    /// and start location updates and/or request location once via the locationManager property on MTMapView.
    /// - Parameters:
    ///    - manager: Optional external CLLocationManager to use.
    ///    - accuracy: Optional desired accuracy to use.
    public func initLocationTracking(using manager: CLLocationManager? = nil, accuracy: CLLocationAccuracy? = nil) {
        locationManager = MTLocationManager(using: manager, accuracy: accuracy)
    }

    private func commonInit() {
        eventProcessor = EventProcessor()
        eventProcessor.delegate = self

        webViewExecutor = WebViewExecutor(frame: frame, eventProcessor: eventProcessor)
        webViewExecutor.delegate = self

        if let webView = webViewExecutor.getWebView() {
            addSubview(webView)
        }

        bridge = MTBridge(executor: webViewExecutor)
        gestureService = MTGestureService(bridge: bridge, eventProcessor: eventProcessor, mapView: self)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if let webView = webViewExecutor.getWebView() {
            webView.frame = bounds
        }
    }

    /// Reloads the map view.
    public func reload() {
        if let webView = webViewExecutor.getWebView() {
            webView.reload()
        }
    }

    package func initializeMap() {
        Task {
            guard let apiKey = await MTConfig.shared.getAPIKey() else {
                MTLogger.log(
                    "Map Init Failed - API key not set! Call MTConfig.shared.setAPIKey first.",
                    type: .criticalError
                )

                return
            }

            if let options {
                await MTConfig.shared.setSessionLogic(options.isSessionLogicEnabled, for: self)
            }

            let isSessionLogicEnabled = await MTConfig.shared.isSessionLogicEnabled

            do {
                try await _ = bridge.execute(InitializeMap(
                    apiKey: apiKey,
                    options: options,
                    referenceStyle: referenceStyleProxy,
                    styleVariant: styleVariantProxy,
                    shouldEnableSessionLogic: isSessionLogicEnabled)
                )

                MTLogger.log("\(MTLogger.infoMarker) - Map Initialized Successfully", type: .info)
            } catch {
                MTLogger.log("\(error)", type: .criticalError)
            }
        }
    }

    package func setProxy(referenceStyle: MTMapReferenceStyle, styleVariant: MTMapStyleVariant?) {
        self.referenceStyleProxy = referenceStyle
        self.styleVariantProxy = styleVariant
    }

    package func addContentDelegate(_ contentDelegate: MTMapViewContentDelegate) {
        let delegate = MTWeakContentDelegate(delegate: contentDelegate)
        contentDelegates[delegate.id] = delegate
    }
}

extension MTMapView: EventProcessorDelegate {
    package func eventProcessor(_ processor: EventProcessor, didTriggerEvent event: MTEvent, with data: MTData?) {
        MTLogger.log("MTEvent triggered: \(event)", type: .event)

        delegate?.mapView(self, didTriggerEvent: event, with: data)

        for contentDelegate in self.contentDelegates.values {
            if let delegate = contentDelegate.delegate {
                delegate.mapView(self, didTriggerEvent: event, with: data)
            } else {
                contentDelegates.removeValue(forKey: contentDelegate.id)
            }
        }

        if event == .didLoad {
            style = MTStyle(for: self, with: referenceStyleProxy, and: styleVariantProxy)
        } else if event == .isReady {
            isInitialized = true
            delegate?.mapViewDidInitialize(self)
            didInitialize?()
        }

        if event == .isIdle, let style {
            style.processLayersQueueIfNeeded()
        }

        handleOptionsChange(event: event)
    }

    private func handleOptionsChange(event: MTEvent) {
        if event == .zoomDidEnd {
            getZoom { [weak self] result in
                switch result {
                case .success(let zoom):
                    self?.options?.setZoom(zoom)
                case .failure(let error):
                    MTLogger.log("\(error)", type: .error)
                }
            }
        } else if event == .dragDidEnd || event == .rotateDidEnd || event == .moveDidEnd {
            getCenter { [weak self] result in
                switch result {
                case .success(let center):
                    if self?.options?.center != center {
                        self?.options?.setCenter(center)
                    }
                case .failure(let error):
                    MTLogger.log("\(error)", type: .error)
                }
            }

            getPitch { [weak self] result in
                switch result {
                case .success(let pitch):
                    if self?.options?.pitch != pitch {
                        self?.options?.setPitch(pitch)
                    }
                case .failure(let error):
                    MTLogger.log("\(error)", type: .error)
                }
            }

            getBearing { [weak self] result in
                switch result {
                case .success(let bearing):
                    if self?.options?.bearing != bearing {
                        self?.options?.setBearing(bearing)
                    }
                case .failure(let error):
                    MTLogger.log("\(error)", type: .error)
                }
            }

            getRoll { [weak self] result in
                switch result {
                case .success(let roll):
                    if self?.options?.roll != roll {
                        self?.options?.setRoll(roll)
                    }
                case .failure(let error):
                    MTLogger.log("\(error)", type: .error)
                }
            }
        }
    }
}

extension MTMapView {
    package func runCommand(_ command: MTCommand, completion: ((Result<Void, MTError>) -> Void)? = nil) {
        Task {
            do {
                try await _ = bridge.execute(command)
                completion?(.success(()))
            } catch {
                MTLogger.log("\(error)", type: .error)

                if let error = error as? MTError {
                    completion?(.failure(error))
                } else {
                    completion?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }
    }

    package func runCommandWithDoubleReturnValue(
        _ command: MTCommand,
        completion: ((Result<Double, MTError>) -> Void)? = nil
    ) {
        Task {
            do {
                let value = try await bridge.execute(command)

                if case .double(let commandValue) = value {
                    completion?(.success(commandValue))
                } else {
                    MTLogger.log("\(command) returned invalid type.", type: .error)
                    completion?(.failure(MTError.unsupportedReturnType(description: "Expected double, got NaN.")))
                }
            } catch {
                MTLogger.log("\(error)", type: .error)
                if let error = error as? MTError {
                    completion?(.failure(error))
                } else {
                    completion?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }
    }

    package func runCommandWithStringReturnValue(
        _ command: MTCommand,
        completion: ((Result<String, MTError>) -> Void)? = nil
    ) {
        Task {
            do {
                let value = try await bridge.execute(command)

                if case .string(let commandValue) = value {
                    completion?(.success(commandValue))
                } else {
                    MTLogger.log("\(command) returned invalid type.", type: .error)
                    completion?(.failure(MTError.unsupportedReturnType(description: "Expected double, got NaN.")))
                }
            } catch {
                MTLogger.log("\(error)", type: .error)
                if let error = error as? MTError {
                    completion?(.failure(error))
                } else {
                    completion?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }
    }

    package func runCommandWithBoolReturnValue(
        _ command: MTCommand,
        completion: ((Result<Bool, MTError>) -> Void)? = nil
    ) {
        Task {
            do {
                let value = try await bridge.execute(command)

                if let commandValue = value.boolValue {
                    completion?(.success(commandValue))
                } else {
                    MTLogger.log("\(command) returned invalid type.", type: .error)
                    completion?(.failure(MTError.unsupportedReturnType(description: "Expected bool, got unknown.")))
                }
            } catch {
                MTLogger.log("\(error)", type: .error)
                if let error = error as? MTError {
                    completion?(.failure(error))
                } else {
                    completion?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }
    }

    package func runCommandWithCoordinateReturnValue(
        _ command: MTCommand,
        completion: ((Result<CLLocationCoordinate2D, MTError>) -> Void)? = nil
    ) {
        Task {
            do {
                let value = try await bridge.execute(command)

                if case .stringDoubleDict(let commandValue) = value {
                    if let lat = commandValue["lat"], let lng = commandValue["lng"] {
                        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        completion?(.success(coordinates))
                    } else if let x = commandValue["x"], let y = commandValue["y"] {
                        let coordinates = CLLocationCoordinate2D(latitude: x, longitude: y)
                        completion?(.success(coordinates))
                    } else {
                        completion?(
                            .failure(
                                MTError.unsupportedReturnType(description: "Expected Coordinates, got invalid type.")
                            )
                        )
                    }
                } else {
                    MTLogger.log("\(command) returned invalid type.", type: .error)
                    completion?(
                        .failure(
                            MTError.unsupportedReturnType(description: "Expected Coordinates, got invalid type.")
                        )
                    )
                }
            } catch {
                MTLogger.log("\(error)", type: .error)
                if let error = error as? MTError {
                    completion?(.failure(error))
                } else {
                    completion?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }
    }
}

extension MTMapView: MTLocationManagerDelegate {
    public func didUpdateLocation(_ location: CLLocation) {
        delegate?.mapView(self, didUpdateLocation: location)
    }

    public func didFailWithError(_ error: Error) {
        MTLogger.log("MTLocationManager didFailWithError \(error)", type: .error)
    }
}

public extension MTMapView {
    /// Pins the map view to its superview edges using auto layout.
    ///
    /// - Note: Map view must be added to the superview before calling the function.
    func pinToSuperviewEdges() {
        guard let superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }
}
