//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineNetworkClientTests.swift
//  MapTilerSDKTests
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("MTOfflineHTTPClient Tests", .serialized)
struct MTOfflineHTTPClientTests {

    @Test("Timeout maps to .timeout error")
    func testTimeout() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = MTOfflineHTTPClient(session: session)
        
        MockURLProtocol.requestHandler = { request in
            throw URLError(.timedOut)
        }
        
        await #expect(throws: MTOfflineHTTPError.timeout) {
            try await client.get(url: URL(string: "http://localhost")!)
        }
    }
    
    @Test("No connection maps to .noConnection error")
    func testNoConnection() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = MTOfflineHTTPClient(session: session)
        
        MockURLProtocol.requestHandler = { request in
            throw URLError(.notConnectedToInternet)
        }
        
        await #expect(throws: MTOfflineHTTPError.offline) {
            try await client.get(url: URL(string: "http://localhost")!)
        }
    }
    
    @Test("Bad response maps to .badResponse error")
    func testBadResponse() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = MTOfflineHTTPClient(session: session)
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 404,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        
        do {
            _ = try await client.get(url: URL(string: "http://localhost")!)
            Issue.record("Expected to throw badResponse error")
        } catch let error as MTOfflineHTTPError {
            #expect(error == .notFound)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
    
    @Test("Success returns data")
    func testSuccess() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = MTOfflineHTTPClient(session: session)
        
        let expectedData = "Hello, World!".data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, expectedData)
        }
        
        let data = try await client.get(url: URL(string: "http://localhost")!)
        #expect(data == expectedData)
    }
}

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
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
    
    override func stopLoading() {
        // Nothing to do
    }
}
