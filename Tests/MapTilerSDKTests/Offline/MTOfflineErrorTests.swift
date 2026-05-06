//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("Offline Error Handling Tests")
struct MTOfflineErrorTests {
    
    // A simple delegate to capture errors
    final class ErrorCaptor: MTOfflineDownloadDelegate, @unchecked Sendable {
        private let lock = NSLock()
        private var _lastError: MTOfflineError?
        private var _lastContext: MTOfflineContext?
        
        var lastError: MTOfflineError? {
            lock.lock(); defer { lock.unlock() }
            return _lastError
        }
        
        var lastContext: MTOfflineContext? {
            lock.lock(); defer { lock.unlock() }
            return _lastContext
        }
        
        func offlineDownloadDidFail(error: MTOfflineError, context: MTOfflineContext) {
            lock.lock(); defer { lock.unlock() }
            _lastError = error
            _lastContext = context
        }

        func offlineDownloadDidSucceed(context: MTOfflineContext) {
            // No-op for this test captor
        }
    }
    
    // Mock URLProtocol to simulate various network responses
    class MockURLProtocol: URLProtocol {
        nonisolated(unsafe) static var handlers: [URL: @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)] = [:]
        static let handlersLock = NSLock()
        
        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
        
        override func startLoading() {
            let handler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))? = MockURLProtocol.handlersLock.withLock {
                MockURLProtocol.handlers[request.url!]
            }
            
            guard let handler = handler else {
                client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
                return
            }
            
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {}
        
        static func setHandler(for url: URL, handler: @escaping @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)) {
            handlersLock.withLock {
                handlers[url] = handler
            }
        }
    }
    
    private func createMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    @Test("Test 404 Not Found error mapping")
    func test404ErrorMapping() async throws {
        let captor = ErrorCaptor()
        let downloader = MTOfflineDownloader(delegate: captor)
        let session = createMockSession()
        let url = URL(string: "https://example.com/404/tile.pbf")!
        
        MockURLProtocol.setHandler(for: url) { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let resource = MTMapResource(url: url, destinationPath: "/tmp/tile404.pbf")
        let task = MTResourceDownloadTask(resource: resource, session: session)
        
        _ = try? await downloader.download([task])
        
        #expect(captor.lastError == .badResponse(statusCode: 404))
        #expect(captor.lastContext?.url == url)
    }
    
    @Test("Test 204 No Content mapping")
    func test204NoContentMapping() async throws {
        let captor = ErrorCaptor()
        let downloader = MTOfflineDownloader(delegate: captor)
        let session = createMockSession()
        let url = URL(string: "https://example.com/204/tile.pbf")!
        
        MockURLProtocol.setHandler(for: url) { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 204, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        let resource = MTMapResource(url: url, destinationPath: "/tmp/tile204.pbf")
        let task = MTResourceDownloadTask(resource: resource, session: session)
        
        _ = try? await downloader.download([task])
        
        #expect(captor.lastError == .noContent)
    }
    
    @Test("Test Content Mismatch mapping (PBF vs HTML)")
    func testContentMismatchMapping() async throws {
        let captor = ErrorCaptor()
        let downloader = MTOfflineDownloader(delegate: captor)
        let session = createMockSession()
        let url = URL(string: "https://example.com/mismatch/tile.pbf")!
        
        MockURLProtocol.setHandler(for: url) { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "text/html"])!
            return (response, "<html><body>Error</body></html>".data(using: .utf8)!)
        }
        
        let resource = MTMapResource(url: url, destinationPath: "/tmp/tileMismatch.pbf")
        let task = MTResourceDownloadTask(resource: resource, session: session)
        
        _ = try? await downloader.download([task])
        
        #expect(captor.lastError == .contentMismatch(expected: "application/x-protobuf", actual: "text/html"))
    }

    @Test("Test Invalid URL error description")
    func testInvalidURLErrorDescription() {
        let error = MTOfflineError.invalidURL("https://invalid-url.com")
        #expect(error.errorDescription == "The provided URL is invalid: https://invalid-url.com.")
    }

    @Test("Test Bad Response error description")
    func testBadResponseErrorDescription() {
        let error = MTOfflineError.badResponse(statusCode: 404)
        #expect(error.errorDescription == "The server returned a bad response with status code: 404.")
    }

    @Test("Test Network Error description")
    func testNetworkErrorDescription() {
        let urlError = URLError(.notConnectedToInternet)
        let error = MTOfflineError.networkError(urlError)
        #expect(error.errorDescription == "A network error occurred: \(urlError.localizedDescription).")
    }

    @Test("Test recovery suggestions")
    func testRecoverySuggestions() {
        #expect(MTOfflineError.invalidURL("").recoverySuggestion == "Ensure that the URL is properly formatted and all required parameters are URL-encoded.")
        #expect(MTOfflineError.badResponse(statusCode: 401).recoverySuggestion == "Verify that your API key is valid and has permission to access this resource.")
        #expect(MTOfflineError.noContent.recoverySuggestion == "Check if the resource is available for the requested region and zoom level.")
        #expect(MTOfflineError.contentMismatch(expected: "pbf", actual: "html").recoverySuggestion == "The server might be returning an error page instead of the requested resource. Check your API key and parameters.")
    }
}

extension NSLock {
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
