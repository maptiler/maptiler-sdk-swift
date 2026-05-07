//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineHTTPServer.swift
//  MapTilerSDK
//

import Foundation
import Network

// A lightweight HTTP server for serving offline map assets.
internal final class MTOfflineHTTPServer: @unchecked Sendable {
    // Shared singleton instance.
    internal static let shared = MTOfflineHTTPServer()

    private var listener: NWListener?
    private var port: NWEndpoint.Port?
    private let queue = DispatchQueue(label: "com.maptiler.offline.server", qos: .userInitiated)

    // Indicates if the server is currently running.
    public private(set) var isRunning = false

    private init() {}

    // Starts the server on the specified port.
    // The port number to listen on defaults to 18080.
    internal func start(port: UInt16 = 18080) throws {
        try queue.sync {
            guard !isRunning else { return }

            let nwPort = NWEndpoint.Port(rawValue: port)!
            let parameters = NWParameters.tcp

            let listener = try NWListener(using: parameters, on: nwPort)

            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    MTLogger.log("Offline server ready on port \(port)", type: .info)
                case .failed(let error):
                    MTLogger.log("Offline server failed: \(error)", type: .error)
                default:
                    break
                }
            }

            listener.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }

            listener.start(queue: queue)
            self.listener = listener
            self.port = nwPort
            self.isRunning = true
        }
    }

    // Stops the server and cancels all active connections.
    internal func stop() {
        queue.sync {
            listener?.cancel()
            listener = nil
            port = nil
            isRunning = false
            MTLogger.log("Offline server stopped", type: .info)
        }
    }

    // Returns the base URL string for the server.
    internal func baseURLString() -> String {
        return queue.sync {
            guard let port = port else { return "" }
            return "http://127.0.0.1:\(port.rawValue)"
        }
    }

    private func handleNewConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        receiveData(from: connection)
    }

    private func receiveData(from connection: NWConnection) {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: 65536
        ) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }

            if let error = error {
                if case .posix(let code) = error, code == .ECANCELED {
                    // Ignore cancellation
                } else {
                    MTLogger.log("Connection receive error: \(error)", type: .error)
                }
                connection.cancel()
                return
            }

            if let data = content, !data.isEmpty {
                self.processData(data, on: connection)
            }

            if isComplete {
                connection.cancel()
            } else if error == nil {
                self.receiveData(from: connection)
            }
        }
    }

    private func processData(_ data: Data, on connection: NWConnection) {
        // Simple manual HTTP parser
        guard let requestString = String(data: data, encoding: .utf8) else {
            connection.cancel()
            return
        }

        let lines = requestString.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else {
            connection.cancel()
            return
        }

        let parts = firstLine.components(separatedBy: " ")
        guard parts.count >= 2 else {
            connection.cancel()
            return
        }

        let method = parts[0]
        let path = parts[1]

        if method == "GET" && (path == "/health" || path == "/health/") {
            sendResponse(statusCode: 200, body: "OK", on: connection)
        } else {
            sendResponse(statusCode: 404, body: "Not Found", on: connection)
        }
    }

    private func sendResponse(statusCode: Int, body: String, on connection: NWConnection) {
        let responseBody = body.data(using: .utf8) ?? Data()
        let statusText = self.statusText(for: statusCode)

        var headerString = ""
        headerString += "HTTP/1.1 \(statusCode) \(statusText)\r\n"
        headerString += "Content-Type: text/plain\r\n"
        headerString += "Content-Length: \(responseBody.count)\r\n"
        headerString += "Connection: close\r\n"
        headerString += "\r\n"

        var responseData = headerString.data(using: .utf8) ?? Data()
        responseData.append(responseBody)

        connection.send(content: responseData, completion: .contentProcessed { error in
            if let error = error {
                MTLogger.log("Send error: \(error)", type: .error)
            }
            connection.cancel()
        })
    }

    private func statusText(for statusCode: Int) -> String {
        switch statusCode {
        case 200: return "OK"
        case 404: return "Not Found"
        default: return "Internal Server Error"
        }
    }
}
