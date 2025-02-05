//
//  WebViewExecutor.swift
//  MapTilerSDK
//

import WebKit

// Class responsible for JS execution in WKWebView
package final class WebViewExecutor: MTCommandExecutable {
    private var webView: WKWebView?

    init(webView: WKWebView) {
        self.webView = webView
    }

    @MainActor
    package func execute(_ command: MTCommand) {
        guard let webView = webView else {
            return
        }

        webView.evaluateJavaScript(command.toJS())
    }
}
