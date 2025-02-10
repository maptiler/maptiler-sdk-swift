//
//  WebViewExecutor.swift
//  MapTilerSDK
//

import WebKit

@MainActor
protocol WebViewExecutorDelegate: AnyObject {
    func webViewExecutor(_ executor: WebViewExecutor, didFinishNavigation navigation: WKNavigation)
    func webViewExecutor(_ executor: WebViewExecutor, didTriggerEvent event: MTEvent)
}

// Class responsible for JS execution in WKWebView
@MainActor
package final class WebViewExecutor: MTCommandExecutable {
    private var webView: WKWebView?
    private var webViewManager: WebViewManager!
    weak var delegate: WebViewExecutorDelegate?

    init(frame: CGRect) {
        webViewManager = WebViewManager()
        webViewManager.delegate = self

        guard let webView = webViewManager.getAttachableWebView(frame: frame) else {
            return
        }

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
    func webViewManager(_ manager: WebViewManager, didTriggerEvent event: MTEvent) {
        delegate?.webViewExecutor(self, didTriggerEvent: event)
    }

    func webViewManager(_ manager: WebViewManager, didFinishNavigation navigation: WKNavigation) {
        delegate?.webViewExecutor(self, didFinishNavigation: navigation)
    }
}
