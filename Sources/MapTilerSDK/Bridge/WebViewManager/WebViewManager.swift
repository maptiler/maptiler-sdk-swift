//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  WebViewManager.swift
//  MapTilerSDK
//

import WebKit
import UIKit

@MainActor
protocol WebViewManagerDelegate: AnyObject {
    func webViewManager(_ manager: WebViewManager, didFinishNavigation navigation: WKNavigation)
}

// Class responsible for initializing webview for JS bridging
@MainActor
package final class WebViewManager: NSObject {
    private var webView: WKWebView?
    package var eventProcessor: EventProcessor!

    weak var delegate: WebViewManagerDelegate?

    init(eventProcessor: EventProcessor) {
        self.eventProcessor = eventProcessor
    }

    func getAttachableWebView(frame: CGRect) -> WKWebView? {
        initWebView(frame: frame)

        return webView
    }

    private func initWebView(frame: CGRect) {
        if let path =
            Bundle.module.path(
                forResource: Constants.JSResources.mapTilerMap,
                ofType: Constants.JSResources.htmlExtension) {
            let url = URL(fileURLWithPath: path)
            let request = URLRequest(url: url)

            let configuration = WKWebViewConfiguration()
            configuration.userContentController = makeUserContentController()
            configuration.allowsInlineMediaPlayback = true

            webView = WKWebView(frame: frame, configuration: configuration)
            webView?.navigationDelegate = self
            webView?.scrollView.contentInsetAdjustmentBehavior = .never

            webView?.load(request)
        }
    }

    private func makeUserContentController() -> WKUserContentController {
        let controller: WKUserContentController = WKUserContentController()

        let errorLoggingScript =
            WKUserScript(
                source: Constants.errorLoggingScript,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
        controller.addUserScript(errorLoggingScript)

        controller.add(self, name: Constants.Error.handler)
        controller.add(self, name: Constants.Map.handler)

        return controller
    }
}

// MARK: - WKNavigationDelegate Implementation
extension WebViewManager: WKNavigationDelegate {
    package func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.webViewManager(self, didFinishNavigation: navigation)
    }
}

// MARK: - Constants
extension WebViewManager {
    enum Constants {
        enum Error {
            static let handler = "errorHandler"
            static let message = "message"
            static let unknown = "Unknown Error"
        }

        enum Map {
            static let handler = "mapHandler"
            static let event = "event"
            static let data = "data"
        }

        enum JSResources {
            static let mapTilerMap = "MapTilerMap"
            static let mapTilerSDK = "maptiler-sdk.umd.min"
            static let mapTilerStyleSheet = "maptiler-sdk"

            static let htmlExtension = "html"
            static let jsExtension = "js"
            static let cssExtension = "css"
        }

        static let errorLoggingScript = """
            window.onerror = function(\(Constants.Error.message)) {
                window.webkit.messageHandlers.errorHandler.postMessage({
                    message: \(Constants.Error.message)
                });
            };
            """
    }
}
