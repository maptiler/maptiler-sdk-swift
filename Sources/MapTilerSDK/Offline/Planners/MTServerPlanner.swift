//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTServerPlanner.swift
//  MapTilerSDK
//

import Foundation

// A server-based planner for offline map regions that estimates download size and plans the required tiles.
internal class MTServerPlanner: MTOfflinePlanner {

    // The URLSession used for network requests.
    private let session: URLSession

    internal init(session: URLSession = .shared) {
        self.session = session
    }

    // Estimates the size and resources required for an offline region.
    internal func estimate(for definition: MTOfflineRegionDefinition) async throws -> MTTileEstimate {
        throw MTOfflinePackError.notImplemented
    }

    internal func generateManifest(
        styleURL: URL,
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        pixelRatio: Float
    ) async throws -> MTManifest {
        throw MTOfflinePackError.notImplemented
    }

    internal func generateManifest(
        mapId: String,
        bbox: MTBoundingBox,
        minZoom: Int,
        maxZoom: Int,
        pixelRatio: Float
    ) async throws -> MTManifest {
        throw MTOfflinePackError.notImplemented
    }

    // Handles a network response, throwing the appropriate MTOfflinePackError for non-success status codes.
    private func handleNetworkResponse(_ response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MTOfflinePackError.networkError(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            return // Success
        case 401, 403:
            throw MTOfflinePackError.unauthorized
        case 404:
            throw MTOfflinePackError.resourceNotFound
        case 429:
            throw MTOfflinePackError.rateLimitExceeded
        default:
            throw MTOfflinePackError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
