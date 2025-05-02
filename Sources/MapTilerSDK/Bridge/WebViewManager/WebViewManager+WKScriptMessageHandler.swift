//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  WebViewManager+WKScriptMessageHandler.swift
//  MapTilerSDK
//

import WebKit

// Handling of error and event messages from JS
extension WebViewManager: WKScriptMessageHandler {
    package func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == Constants.Error.handler {
            handleError(with: message)
        } else if message.name == Constants.Map.handler {
            handleEvent(with: message)
        }
    }

    private func handleError(with message: WKScriptMessage) {
        if let errorInfo = message.body as? [String: Any] {
            let message = errorInfo[Constants.Error.message] as? String ?? Constants.Error.unknown

            handleContextFailure(message: message)
        } else if let error = message.body as? String {
            let message = error
            handleContextFailure(message: message)
        }
    }

    private func handleContextFailure(message: String) {
        if message == "webglcontextlost" {
            MTLogger.log("Context lost, consider calling reload on MTMapView", type: .criticalError)
        }
    }

    private func handleEvent(with message: WKScriptMessage) {
        if let messageBody = message.body as? [String: Any], let event = messageBody[Constants.Map.event] as? String {
            if let data = messageBody[Constants.Map.data] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let decoder = JSONDecoder()
                    let eventData = try decoder.decode(MTData.self, from: jsonData)

                    eventProcessor.registerEvent(MTEvent(rawValue: event), with: eventData)
                } catch {
                    MTLogger.log("Data parsing error for event: \(event): \(error)", type: .error)
                }
            } else {
                eventProcessor.registerEvent(MTEvent(rawValue: event))
            }
        }
    }
}
