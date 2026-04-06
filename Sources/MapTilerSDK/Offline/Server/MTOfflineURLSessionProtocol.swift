//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapResource.swift
//  MapTilerSDK
//

import Foundation

// A protocol to allow mocking URLSession for testing
internal protocol MTOfflineURLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func download(for request: URLRequest) async throws -> (URL, URLResponse)
}

extension URLSession: MTOfflineURLSessionProtocol {
    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        return try await self.download(for: request, delegate: nil)
    }
}
