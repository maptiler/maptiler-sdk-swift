//
//  WebViewExecutor.swift
//  MapTilerSDK
//

import WebKit

@MainActor
protocol WebViewExecutorDelegate: AnyObject {
    func webViewExecutor(_ executor: WebViewExecutor, didFinishNavigation navigation: WKNavigation)
}

// Class responsible for JS execution in WKWebView
@MainActor
package final class WebViewExecutor: MTCommandExecutable {
    private var webView: WKWebView?
    private var webViewManager: WebViewManager!
    private var eventProcessor: EventProcessor!

    weak var delegate: WebViewExecutorDelegate?

    init(frame: CGRect, eventProcessor: EventProcessor) {
        self.eventProcessor = eventProcessor

        webViewManager = WebViewManager(eventProcessor: eventProcessor)
        webViewManager.delegate = self

        guard let webView = webViewManager.getAttachableWebView(frame: frame) else {
            return
        }

        webView.scrollView.isScrollEnabled = false
        self.webView = webView

    }

    func getWebView() -> WKWebView? {
        return webView
    }

    @MainActor
    package func execute(_ command: MTCommand) {
        guard let webView = webView else {
            return
        }

        webView.evaluateJavaScript(command.toJS())
    }
}

extension WebViewExecutor: WebViewManagerDelegate {
    func webViewManager(_ manager: WebViewManager, didFinishNavigation navigation: WKNavigation) {
        delegate?.webViewExecutor(self, didFinishNavigation: navigation)
    }
}
