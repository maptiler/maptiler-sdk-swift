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
        if let json = message.body as? String,
            let data = json.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let msg = dict[Constants.Error.message] as? String { handleContextFailure(message: msg) }
        } else if let error = message.body as? String {
            handleContextFailure(message: error)
        }
    }

    private func handleContextFailure(message: String) {
        if message == "webglcontextlost" {
            MTLogger.log("Context lost, consider calling reload on MTMapView", type: .criticalError)
        }
    }

    private func handleEvent(with message: WKScriptMessage) {
        if let json = message.body as? String,
            let data = json.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let event = dict[Constants.Map.event] as? String {
            if let payload = dict[Constants.Map.data] as? [String: Any],
                JSONSerialization.isValidJSONObject(payload),
                let jsonData = try? JSONSerialization.data(withJSONObject: payload) {
                let decoder = JSONDecoder()
                if let eventData = try? decoder.decode(MTData.self, from: jsonData) {
                    eventProcessor.registerEvent(MTEvent(rawValue: event), with: eventData)
                    return
                }
            }
            eventProcessor.registerEvent(MTEvent(rawValue: event))
        }
    }
}
