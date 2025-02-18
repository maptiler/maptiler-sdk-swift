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
    public var options: MTMapOptions = MTMapOptions()

    /// Service responsible for gestures handling
    public var gestureService: MTGestureService = MTGestureService()

    /// Delegate object responsible for event propagation
    public weak var delegate: MTMapViewDelegate?

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

    private func commonInit() {
        webViewExecutor = WebViewExecutor(frame: frame)
        webViewExecutor.delegate = self

        if let webView = webViewExecutor.getWebView() {
            addSubview(webView)
        }

        MTBridge.shared.setExecutor(webViewExecutor)
    }

    package func initializeMap() {
        Task {
            guard let apiKey = await MTConfig.shared.getAPIKey() else {
                return
            }

            await MTBridge.shared.execute(InitializeMap(
                apiKey: apiKey,
                options: options,
                referenceStyle: referenceStyle,
                styleVariant: styleVariant)
            )

            delegate?.mapViewDidInitialize(self)
        }
    }
}
