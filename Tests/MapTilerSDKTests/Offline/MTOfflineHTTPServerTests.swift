//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite(.serialized)
struct MTOfflineHTTPServerTests {
    
    @Test func serverLifecycle() async throws {
        let server = MTOfflineHTTPServer.shared
        
        // Ensure it's stopped before starting
        server.stop()
        
        // Start server
        try server.start(port: 18081)
        #expect(server.isRunning)
        #expect(server.baseURLString() == "http://127.0.0.1:18081")
        
        // Stop server
        server.stop()
        #expect(!server.isRunning)
        #expect(server.baseURLString() == "")
    }
    
    @Test func healthCheck() async throws {
        let server = MTOfflineHTTPServer.shared
        
        // Ensure it's stopped before starting
        server.stop()
        
        try server.start(port: 18082)
        defer { server.stop() }
        
        let url = URL(string: "\(server.baseURLString())/health")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Issue.record("Response is not HTTPURLResponse")
            return
        }
        
        #expect(httpResponse.statusCode == 200)
        #expect(String(data: data, encoding: .utf8) == "OK")
    }
    
    @Test func notFound() async throws {
        let server = MTOfflineHTTPServer.shared
        
        // Ensure it's stopped before starting
        server.stop()
        
        try server.start(port: 18083)
        defer { server.stop() }
        
        let url = URL(string: "\(server.baseURLString())/unknown")!
        
        let (_, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Issue.record("Response is not HTTPURLResponse")
            return
        }
        
        #expect(httpResponse.statusCode == 404)
    }

    @Test func restartServer() async throws {
        let server = MTOfflineHTTPServer.shared
        
        // Ensure it's stopped before starting
        server.stop()
        
        try server.start(port: 18084)
        #expect(server.isRunning)
        server.stop()
        #expect(!server.isRunning)
        
        try server.start(port: 18084)
        #expect(server.isRunning)
        server.stop()
        #expect(!server.isRunning)
    }
}
