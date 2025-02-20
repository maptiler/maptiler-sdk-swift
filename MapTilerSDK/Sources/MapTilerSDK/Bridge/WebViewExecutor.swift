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

        webView.evaluateJavaScript(command.toJS()) { _, error in
            // Log errors based on the log level.
            // Most of the JS functions return the Map itself which is not required in the native code.
            if let error = error as? WKError, error.code != .javaScriptResultTypeIsUnsupported {
                Task {
                    let commandMessage = "Bridging error occurred for \(command)."
                    let errorMessage = await MTConfig.shared.logLevel == .debug(verbose: true)
                    ? "\(commandMessage) - \(error.errorUserInfo.debugDescription)"
                    : commandMessage
                    MTLogger.log("\(errorMessage)", type: .error)
                }
            }
        }
    }
}

extension WebViewExecutor: WebViewManagerDelegate {
    func webViewManager(_ manager: WebViewManager, didFinishNavigation navigation: WKNavigation) {
        delegate?.webViewExecutor(self, didFinishNavigation: navigation)
    }
}
