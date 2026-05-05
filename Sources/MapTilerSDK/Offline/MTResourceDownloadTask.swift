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
        let (data, response) = try await session.data(from: resource.url)

        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
            throw MTOfflinePackError.networkError(URLError(.badServerResponse))
        }

        try Task.checkCancellation()

        guard let dest = destinationURL else { return }
        try await MTOfflineStorage.write(data, to: dest)
    }
}
