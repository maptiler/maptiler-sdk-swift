//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
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
    private let exceptionKey: String = "WKJavaScriptExceptionMessage"

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
    package func execute(_ command: MTCommand) async throws -> MTBridgeReturnType {
        guard let webView = webView else {
            throw MTError.bridgeNotLoaded
        }

        let isVerbose = await MTConfig.shared.logLevel == .debug(verbose: true)

        return try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(command.toJS()) { [weak self] result, error in
                if let error = error {
                    // Log errors based on the log level.
                    // Most of the JS functions return the Map itself which is not supported in the native code.
                    if let error = error as? WKError, error.code != .javaScriptResultTypeIsUnsupported {
                        if isVerbose {
                            let commandMessage = "Bridging error occurred for \(command)"
                            MTLogger.log("\(commandMessage): \(error.errorUserInfo.debugDescription)", type: .error)
                        }

                        if let reason = error.errorUserInfo[self?.exceptionKey ?? ""] as? String {
                            let exception = MTException(code: error.code.rawValue, reason: reason)
                            continuation.resume(throwing: MTError.exception(body: exception))
                        } else {
                            continuation.resume(throwing: MTError.unknown(description: "\(error)"))
                        }
                    } else { // Execution completed successfully, but with unsupported type. Log based on log level.
                        if isVerbose {
                            MTLogger.log("\(command) completed with unsupported return type.", type: .warning)
                        }

                        continuation.resume(returning: .unsupportedType)
                    }
                } else { // Pass result, handle if type is invalid.
                    do {
                        let parsedResult = try MTBridgeReturnType(from: result)
                        continuation.resume(returning: parsedResult)
                    } catch {
                        continuation.resume(throwing: MTError.invalidResultType(description: result.debugDescription))
                    }
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
