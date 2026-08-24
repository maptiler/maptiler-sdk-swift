//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapResource.swift
//  MapTilerSDK
//

import Foundation

// A centralized HTTP GET wrapper to handle network requests for the offline module
internal actor MTOfflineHTTPClient {
    private let session: MTOfflineURLSessionProtocol
    let timeoutInterval: TimeInterval
    let userAgent: String

    init(
        session: MTOfflineURLSessionProtocol = URLSession.shared,
        timeoutInterval: TimeInterval = 30,
        userAgent: String = MTConfig.customUserAgent
    ) {
        self.session = session
        self.timeoutInterval = timeoutInterval
        self.userAgent = userAgent
    }

    private func createRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeoutInterval
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }

    // Fetches the contents of the URL and returns it as Data.
    func get(url: URL) async throws -> Data {
        let normalizedURL = await MTURLNormalizer.normalize(url: url)
        let request = createRequest(for: normalizedURL)
        let retryPolicy = MTNetworkRetryPolicy(maxAttempts: 3)

        return try await retryPolicy.execute { [self] in
            do {
                let (data, response) = try await session.data(for: request)
                try response.validateHTTPStatus()
                try response.validateContentLength(dataCount: data.count)
                return data
            } catch let error as MTOfflineHTTPError {
                throw error
            } catch let error as MTOfflinePackError {
                throw error
            } catch let urlError as URLError {
                throw mapURLError(urlError)
            } catch {
                throw MTOfflineHTTPError.unknown(error.localizedDescription)
            }
        }
    }

    // Downloads the contents of the URL directly to a specified file URL.
    func download(url: URL, to destinationURL: URL) async throws {
        let normalizedURL = await MTURLNormalizer.normalize(url: url)
        let request = createRequest(for: normalizedURL)
        let retryPolicy = MTNetworkRetryPolicy(maxAttempts: 3)

        try await retryPolicy.execute { [self] in
            do {
                let (tempURL, response) = try await session.download(for: request)
                try response.validateHTTPStatus()

                // Validate downloaded file size
                let attributes = try FileManager.default.attributesOfItem(atPath: tempURL.path)
                if let fileSize = attributes[.size] as? Int64 {
                    try response.validateContentLength(dataCount: Int(fileSize))
                }

                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            } catch let error as MTOfflineHTTPError {
                throw error
            } catch let error as MTOfflinePackError {
                throw error
            } catch let urlError as URLError {
                throw mapURLError(urlError)
            } catch {
                throw MTOfflineHTTPError.unknown(error.localizedDescription)
            }
        }
    }

    private nonisolated func mapURLError(_ urlError: URLError) -> MTOfflineHTTPError {
        switch urlError.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .offline
        default:
            return .networkError(urlError)
        }
    }
}
