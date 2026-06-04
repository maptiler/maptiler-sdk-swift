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
    private var _port: NWEndpoint.Port?
    private let queue = DispatchQueue(label: "com.maptiler.offline.server", qos: .userInitiated)
    private let lock = NSLock()
    private let router = MTOfflineRouter()

    private var _isRunning = false
    public var isRunning: Bool {
        lock.lock(); defer { lock.unlock() }
        return _isRunning
    }

    private init() {}

    private class ContinuationWrapper: @unchecked Sendable {
        private var continuation: CheckedContinuation<NWEndpoint.Port, Error>?
        private let wrapperLock = NSLock()

        init(_ continuation: CheckedContinuation<NWEndpoint.Port, Error>) {
            self.continuation = continuation
        }

        func resume(returning port: NWEndpoint.Port) {
            wrapperLock.lock()
            defer { wrapperLock.unlock() }
            if let cont = continuation {
                cont.resume(returning: port)
                continuation = nil
            }
        }

        func resume(throwing error: Error) {
            wrapperLock.lock()
            defer { wrapperLock.unlock() }
            if let cont = continuation {
                cont.resume(throwing: error)
                continuation = nil
            }
        }
    }

    private func checkIsRunning() -> NWEndpoint.Port? {
        lock.lock()
        defer { lock.unlock() }
        if _isRunning, let p = _port {
            return p
        }
        return nil
    }

    private func setServerState(port: NWEndpoint.Port?, isRunning: Bool, listener: NWListener? = nil) {
        lock.lock()
        defer { lock.unlock() }
        if let port = port {
            self._port = port
        }
        self._isRunning = isRunning
        if let listener = listener {
            self.listener = listener
        }
    }

    // Starts the server on the specified port.
    // The port number to listen on defaults to 18080.
    internal func start(port: UInt16 = 18080) async throws {
        if let existingPort = checkIsRunning() {
            return
        }

        // swiftlint:disable all
        let actualPort = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<NWEndpoint.Port, Error>) in
            let wrapper = ContinuationWrapper(continuation)

            let nwPort = NWEndpoint.Port(rawValue: port)!
            let parameters = NWParameters.tcp

            var targetPort = nwPort
            var listener: NWListener?

            do {
                listener = try NWListener(using: parameters, on: targetPort)
            } catch {
                MTLogger.log("Port \(port) is in use, falling back to any available port", type: .info)
                targetPort = .any
                do {
                    listener = try NWListener(using: parameters, on: .any)
                } catch {
                    wrapper.resume(throwing: error)
                    return
                }
            }

            guard let validListener = listener else {
                wrapper.resume(throwing: MTError.offlineServerFailed)
                return
            }

            validListener.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    let listenerPort = validListener.port ?? .any
                    MTLogger.log("Offline server ready on port \(listenerPort.rawValue)", type: .info)
                    self?.setServerState(port: listenerPort, isRunning: true)
                    wrapper.resume(returning: listenerPort)
                case .failed(let error):
                    MTLogger.log("Offline server failed: \(error)", type: .error)
                    self?.setServerState(port: nil, isRunning: false)
                    wrapper.resume(throwing: error)
                case .cancelled:
                    MTLogger.log("Offline server cancelled", type: .info)
                    self?.setServerState(port: nil, isRunning: false)
                    wrapper.resume(throwing: MTError.offlineServerFailed)
                default:
                    break
                }
            }

            validListener.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }

            self.setServerState(port: nil, isRunning: false, listener: validListener)
            validListener.start(queue: queue)
        }

        // swiftlint:enable all

        self.setServerState(port: actualPort, isRunning: true)
    }

    // Stops the server and cancels all active connections.
    internal func stop() {
        lock.lock()
        listener?.cancel()
        listener = nil
        _port = nil
        _isRunning = false
        lock.unlock()
        MTLogger.log("Offline server stopped", type: .info)
    }

    private func handleStyleJSON(at url: URL, on connection: NWConnection) {
        guard let fileData = try? Data(contentsOf: url),
            let jsonObject = try? JSONSerialization.jsonObject(with: fileData) as? [String: Any] else {
            sendResponse(
                statusCode: 404,
                body: Data("Not Found".utf8),
                mimeType: "text/plain",
                on: connection
            )
            return
        }

        let packID = url.deletingLastPathComponent().lastPathComponent

        var downloadedMaxZoom: Int?
        if let manifest = try? MTOfflineStorage.loadManifest(for: packID) {
            downloadedMaxZoom = manifest.metadata.maxZoom
        }

        let processor = MTStyleProcessor(baseURL: self.baseURLString(), packName: packID)
        let transformed = processor.transform(style: jsonObject, maxZoom: downloadedMaxZoom)

        if let transformedData = try? JSONSerialization.data(withJSONObject: transformed, options: []) {
            sendResponse(
                statusCode: 200,
                body: transformedData,
                mimeType: "application/json",
                on: connection
            )
        } else {
            sendResponse(
                statusCode: 500,
                body: Data("Internal Server Error".utf8),
                mimeType: "text/plain",
                on: connection
            )
        }
    }
}

// MARK: - HTTP Server Logic
extension MTOfflineHTTPServer {
    // Returns the base URL string for the server.
    internal func baseURLString() -> String {
        lock.lock(); defer { lock.unlock() }
        guard let port = _port else { return "" }
        return "http://127.0.0.1:\(port.rawValue)"
    }

    private func handleNewConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        receiveData(from: connection, buffer: Data())
    }

    private func receiveData(from connection: NWConnection, buffer: Data) {
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

            var currentBuffer = buffer
            if let data = content, !data.isEmpty {
                currentBuffer.append(data)
            }

            // Check if we have received the full HTTP headers
            if let range = currentBuffer.range(of: Data("\r\n\r\n".utf8)) {
                let headerData = currentBuffer.prefix(upTo: range.lowerBound)
                self.processData(headerData, on: connection)
            } else if isComplete {
                connection.cancel()
            } else {
                // Continue reading from the socket until we get the full headers
                self.receiveData(from: connection, buffer: currentBuffer)
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
        let path = (parts[1] as NSString).removingPercentEncoding ?? parts[1]

        MTLogger.log("Offline server GET \(path)", type: .info)

        if method == "GET" {
            handleGetRequest(path: path, on: connection)
        } else {
            sendResponse(
                statusCode: 405,
                body: Data("Method Not Allowed".utf8),
                mimeType: "text/plain",
                on: connection
            )
        }
    }

    private func handleGetRequest(path: String, on connection: NWConnection) {
        if path == "/health" || path == "/health/" {
            sendResponse(
                statusCode: 200,
                body: Data("OK".utf8),
                mimeType: "text/plain",
                on: connection
            )
        } else if let resolved = router.resolve(path: path) {
            // Dynamically transform style.json to inject the correct baseURL with the current port
            if resolved.url.lastPathComponent == "style.json" {
                handleStyleJSON(at: resolved.url, on: connection)
                return
            }

            if let fileData = try? Data(contentsOf: resolved.url) {
                sendResponse(statusCode: 200, body: fileData, mimeType: resolved.mimeType, on: connection)
            } else {
                sendResponse(
                    statusCode: 404,
                    body: Data("Not Found".utf8),
                    mimeType: "text/plain",
                    on: connection
                )
            }
        } else {
            sendResponse(
                statusCode: 404,
                body: Data("Not Found".utf8),
                mimeType: "text/plain",
                on: connection
            )
        }
    }

    private func sendResponse(statusCode: Int, body: Data, mimeType: String, on connection: NWConnection) {
        let statusText = self.statusText(for: statusCode)

        var headerString = ""
        headerString += "HTTP/1.1 \(statusCode) \(statusText)\r\n"
        headerString += "Content-Type: \(mimeType)\r\n"
        headerString += "Content-Length: \(body.count)\r\n"
        headerString += "Access-Control-Allow-Origin: *\r\n"
        headerString += "Connection: close\r\n"
        headerString += "\r\n"

        var responseData = headerString.data(using: .utf8) ?? Data()
        responseData.append(body)

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
        case 405: return "Method Not Allowed"
        default: return "Internal Server Error"
        }
    }
}
