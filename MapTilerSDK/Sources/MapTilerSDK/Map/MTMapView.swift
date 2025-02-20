//
//  MTMapView.swift
//  MapTilerSDK
//

import UIKit
import WebKit

/// Delegate responsible for map event propagation
@MainActor
public protocol MTMapViewDelegate: AnyObject {
    func mapViewDidInitialize(_ mapView: MTMapView)
    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent)
}

/// Object representing the map on the screen.
///
/// Exposes methods and properties that enable changes to the map,
/// and fires events that can be interacted with.
open class MTMapView: UIView {
    /// Current reference style of the map object.
    public var referenceStyle: MTMapReferenceStyle = .streets

    /// Current style variant of the map object.
    public var styleVariant: MTMapStyleVariant?

    /// Current options of the map object.
    public var options: MTMapOptions? = MTMapOptions()

    /// Service responsible for gestures handling
    public var gestureService: MTGestureService!

    /// Delegate object responsible for event propagation
    public weak var delegate: MTMapViewDelegate?

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
        self.referenceStyle = referenceStyle
        self.styleVariant = styleVariant

        commonInit()
    }

    convenience public init(options: MTMapOptions?) {
        self.init()

        self.options = options

        commonInit()
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
                MTLogger.log("Map Init Failed - API key not set! Call MTConfig.shared.setAPIKey first.", type: .error)

                return
            }

            await bridge.execute(InitializeMap(
                apiKey: apiKey,
                options: options,
                referenceStyle: referenceStyle,
                styleVariant: styleVariant)
            )

            delegate?.mapViewDidInitialize(self)
        }
    }
}

extension MTMapView: EventProcessorDelegate {
    package func eventProcessor(_ processor: EventProcessor, didTriggerEvent event: MTEvent) {
        delegate?.mapView(self, didTriggerEvent: event)
    }
}
