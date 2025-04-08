//
//  MTMapView.swift
//  MapTilerSDK
//

import UIKit
import WebKit
import CoreLocation

/// Delegate responsible for map event propagation
@MainActor
public protocol MTMapViewDelegate: AnyObject {
    func mapViewDidInitialize(_ mapView: MTMapView)
    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?)
    func mapView(_ mapView: MTMapView, didUpdateLocation location: CLLocation)
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
open class MTMapView: UIView {
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

    public private(set) var isInitialized: Bool = false

    public var didInitialize: (() -> Void)?

    package var bridge: MTBridge!

    package var eventProcessor: EventProcessor!

    private var webViewExecutor: WebViewExecutor!

    override public init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

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

    convenience public init(options: MTMapOptions?) {
        self.init()

        self.options = options

        commonInit()
    }

    /// Initializes location tracking manager.
    ///
    /// In order to track user location you have to initalize the MLLocationManager,
    /// add neccessary Privacy Location messages to info.plist, subscribe to MTLocationManagerDelegate
    /// and start location updates and/or request location once via locationManager property on MTMapView.
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
        gestureService = MTGestureService(bridge: bridge, eventProcessor: eventProcessor)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if let webView = webViewExecutor.getWebView() {
            webView.frame = bounds
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

            do {
                try await _ = bridge.execute(InitializeMap(
                    apiKey: apiKey,
                    options: options,
                    referenceStyle: referenceStyleProxy,
                    styleVariant: styleVariantProxy)
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
}

extension MTMapView: EventProcessorDelegate {
    package func eventProcessor(_ processor: EventProcessor, didTriggerEvent event: MTEvent, with data: MTData?) {
        MTLogger.log("MTEvent triggered: \(event)", type: .event)

        delegate?.mapView(self, didTriggerEvent: event, with: data)

        if event == .didLoad {
            style = MTStyle(for: self, with: referenceStyleProxy, and: styleVariantProxy)

            isInitialized = true
            delegate?.mapViewDidInitialize(self)
            didInitialize?()
        }
    }
}

extension MTMapView {
    package func runCommand(_ command: MTCommand, completion: ((Result<Void, MTError>) -> Void)? = nil) {
        Task {
            do {
                try await bridge.execute(command)
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
}

extension MTMapView: MTLocationManagerDelegate {
    public func didUpdateLocation(_ location: CLLocation) {
        delegate?.mapView(self, didUpdateLocation: location)
    }

    public func didFailWithError(_ error: Error) {
        MTLogger.log("MTLocationManager didFailWithError \(error)", type: .error)
    }
}
