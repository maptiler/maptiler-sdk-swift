//
//  MTMapView.swift
//  MapTilerSDK
//

import UIKit
import WebKit

/// Object representing the map on the screen.
///
/// Exposes methods and properties that enable changes to the map,
/// and fires events that can be interacted with.
open class MTMapView: UIView {
    private var webViewExecutor: WebViewExecutor!

    /// A camera representing the current viewpoint of the map.
    public private(set) var camera: MTMapCamera = MTMapCamera.getCameraFromMapStyle()

    /// Current reference style of the map object.
    public var referenceStyle: MTMapReferenceStyle = .streets

    /// Current style variant of the map object.
    public var styleVariant: MTMapStyleVariant?

    /// Current options of the map object.
    public var options: MTMapOptions = MTMapOptions()

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

    private func initializeMap() {
        Task {
            guard let apiKey = await MTConfig.shared.getAPIKey() else {
                return
            }

            camera = MTMapCamera.getCameraWith(options)

            await MTBridge.shared.execute(InitializeMap(
                apiKey: apiKey,
                options: options,
                referenceStyle: referenceStyle,
                styleVariant: styleVariant)
            )
        }
    }
}

extension MTMapView: WebViewExecutorDelegate {
    package func webViewExecutor(_ executor: WebViewExecutor, didFinishNavigation navigation: WKNavigation) {
        initializeMap()
    }
}
