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

        // Prefer callAsyncJavaScript on iOS 15+; fallback to evaluateJavaScript on older versions.
        let js: String = command.toJS()

        if #available(iOS 15.0, *) {
            do {
                // On iOS 15+, callAsyncJavaScript executes the string as a function body.
                // For value-returning commands, prepend an explicit `return`.
                let leftTrimmed = js.drop { $0.isWhitespace || $0.isNewline }
                let needsReturn = (command is MTValueCommand) && !leftTrimmed.hasPrefix("return ")

                let jsToExecute = needsReturn ? "return \(leftTrimmed)" : js

                let result = try await webView.callAsyncJavaScript(
                    jsToExecute,
                    arguments: [:],
                    in: nil,
                    contentWorld: .page
                )
                return try MTBridgeReturnType(from: result)
            } catch {
                if isVerbose {
                    MTLogger.log(
                        "Bridging error occurred for: \(command): \(error)",
                        type: .warning
                    )
                }
                return .unsupportedType
            }
        // swiftlint:disable indentation_width
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                webView.evaluateJavaScript(js) { [weak self] result, error in
                    if let error = error {
                        if let error = error as? WKError,
                           error.code != .javaScriptResultTypeIsUnsupported {
                            if isVerbose {
                                let commandMessage = "Bridging error occurred for \(command)"
                                MTLogger.log(
                                    "\(commandMessage): \(error.errorUserInfo.debugDescription)",
                                    type: .error
                                )
                            }
                            if let reason = error.errorUserInfo[self?.exceptionKey ?? ""] as? String {
                                let exception = MTException(code: error.code.rawValue, reason: reason)
                                continuation.resume(throwing: MTError.exception(body: exception))
                            } else {
                                continuation.resume(throwing: MTError.unknown(description: "\(error)"))
                            }
                        } else {
                            if isVerbose {
                                MTLogger.log(
                                    "\(command) completed with unsupported return type.",
                                    type: .warning
                                )
                            }
                            continuation.resume(returning: .unsupportedType)
                        }
                    } else {
                        do {
                            let parsedResult = try MTBridgeReturnType(from: result)
                            continuation.resume(returning: parsedResult)
                        } catch {
                            continuation.resume(
                                throwing: MTError.invalidResultType(
                                    description: result.debugDescription
                                )
                            )
                        }
                    }
                }
            }
        }
        // swiftlint:enable indentation_width
    }
}

extension WebViewExecutor: WebViewManagerDelegate {
    func webViewManager(_ manager: WebViewManager, didFinishNavigation navigation: WKNavigation) {
        delegate?.webViewExecutor(self, didFinishNavigation: navigation)
    }
}
