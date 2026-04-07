//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTOfflineNetworkClient.swift
//  MapTilerSDK
//

import Foundation

// Internal HTTP GET wrapper designed specifically for the Offline Module's needs.
internal actor MTOfflineNetworkClient {
    private let session: URLSession

    // Initializes a new network client.
    init(
        timeoutIntervalForRequest: TimeInterval = 30.0,
        timeoutIntervalForResource: TimeInterval = 60.0,
        urlSession: URLSession? = nil
    ) {
        if let session = urlSession {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
            configuration.timeoutIntervalForResource = timeoutIntervalForResource
            self.session = URLSession(configuration: configuration)
        }
    }

    // Performs an HTTP GET request to the provided URL.
    func get(url: URL) async throws -> Data {
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw MTOfflineNetworkError.unknown("Response is not an HTTPURLResponse")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw MTOfflineNetworkError.badResponse(statusCode: httpResponse.statusCode)
            }

            return data
        } catch let error as MTOfflineNetworkError {
            throw error
        } catch let error as URLError {
            throw mapURLError(error)
        } catch {
            throw MTOfflineNetworkError.unknown(error.localizedDescription)
        }
    }

    // Performs an HTTP GET request to the provided URL string.
    func get(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw MTOfflineNetworkError.invalidURL
        }
        return try await get(url: url)
    }

    private func mapURLError(_ error: URLError) -> MTOfflineNetworkError {
        switch error.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .noConnection
        case .badURL, .unsupportedURL:
            return .invalidURL
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
