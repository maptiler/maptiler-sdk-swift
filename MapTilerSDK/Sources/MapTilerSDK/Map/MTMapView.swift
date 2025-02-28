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
    func mapView(_ mapView: MTMapView, didTriggerEvent event: MTEvent, with data: MTData?)
}

/// Object representing the map on the screen.
///
/// Exposes methods and properties that enable changes to the map,
/// and fires events that can be interacted with.
open class MTMapView: UIView {
    /// Proxy style object of the map.
    public private(set) var style: MTStyle?

    private var referenceStyleProxy: MTMapReferenceStyle = .streets
    private var styleVariantProxy: MTMapStyleVariant?

    /// Current options of the map object.
    public var options: MTMapOptions? = MTMapOptions()

    /// Service responsible for gestures handling
    public var gestureService: MTGestureService!

    /// Delegate object responsible for event propagation
    public weak var delegate: MTMapViewDelegate?

    public private(set) var isInitialized: Bool = false

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
                try await bridge.execute(InitializeMap(
                    apiKey: apiKey,
                    options: options,
                    referenceStyle: referenceStyleProxy,
                    styleVariant: styleVariantProxy)
                )

                isInitialized = true
                delegate?.mapViewDidInitialize(self)

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
        }
    }
}

extension MTMapView {
    package func runCommand(_ command: MTCommand) async {
        do {
            try await bridge.execute(command)
        } catch {
            MTLogger.log("\(error)", type: .error)
        }
    }

    package func runCommandWithDoubleReturnValue(_ command: MTCommand) async -> Double {
        do {
            let value = try await bridge.execute(command)

            if case .double(let commandValue) = value {
                return commandValue
            } else {
                MTLogger.log("\(command) returned invalid type.", type: .error)
                return .nan
            }
        } catch {
            MTLogger.log("\(error)", type: .error)
            return .nan
        }
    }

    package func runCommandWithStringReturnValue(_ command: MTCommand) async -> String {
        do {
            let value = try await bridge.execute(command)

            if case .string(let commandValue) = value {
                return commandValue
            } else {
                MTLogger.log("\(command) returned invalid type.", type: .error)
                return ""
            }
        } catch {
            MTLogger.log("\(error)", type: .error)
            return ""
        }
    }
}
