//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTResourceDownloadTask.swift
//  MapTilerSDK
//

import Foundation

// A concrete download task that fetches a single map resource.
internal struct MTResourceDownloadTask: MTDownloadTask {
    internal let id: String
    internal let resource: MTMapResource
    internal var destinationURL: URL? { URL(fileURLWithPath: resource.destinationPath) }

    private let session: URLSession

    internal init(resource: MTMapResource, session: URLSession = MTConfig.sharedURLSession) {
        self.id = resource.url.absoluteString
        self.resource = resource
        self.session = session
    }

    internal func execute() async throws {
        let retryPolicy = MTNetworkRetryPolicy(maxAttempts: 3)

        do {
            try await retryPolicy.execute {
                let (data, response) = try await session.data(from: resource.url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw MTOfflineError.networkError(URLError(.badServerResponse))
                }

                switch httpResponse.statusCode {
                case 204:
                    throw MTOfflineError.noContent
                case 200...299:
                    break
                default:
                    throw MTOfflineError.badResponse(statusCode: httpResponse.statusCode)
                }

                // Check for content mismatch (e.g. expected PBF but got HTML)
                try validateContentType(httpResponse: httpResponse, resourceURL: resource.url)

                try response.validateContentLength(dataCount: data.count)

                try Task.checkCancellation()

                guard let dest = destinationURL else { return }
                try await MTOfflineStorage.write(data, to: dest)
            }
        } catch let error as MTOfflineError {
            throw error
        } catch let error as URLError {
            throw MTOfflineError.networkError(error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw MTOfflineError.fileSystemError(error.localizedDescription)
        }
    }

    private func validateContentType(httpResponse: HTTPURLResponse, resourceURL: URL) throws {
        guard let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") else {
            return
        }

        let urlPath = resourceURL.path.lowercased()
        if urlPath.hasSuffix(".pbf") || urlPath.hasSuffix(".mvt") {
            if contentType.contains("text/html") {
                throw MTOfflineError.contentMismatch(
                    expected: "application/x-protobuf",
                    actual: contentType
                )
            }
        } else if urlPath.hasSuffix(".png") || urlPath.hasSuffix(".jpg") || urlPath.hasSuffix(".webp") {
            if contentType.contains("text/html") || contentType.contains("application/json") {
                throw MTOfflineError.contentMismatch(
                    expected: "image/*",
                    actual: contentType
                )
            }
        }
    }
}
