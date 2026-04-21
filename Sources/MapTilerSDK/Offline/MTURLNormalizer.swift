//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

// Normalizes MapTiler URLs for offline usage.
internal struct MTURLNormalizer {

    // Normalizes a URL by ensuring it uses the HTTPS scheme, points to the correct MapTiler API host,
    // and includes the API key from `MTConfig.shared` if it isn't already present.
    internal static func normalize(url: URL) async -> URL {
        let apiKey = await MTConfig.shared.getAPIKey() ?? ""
        return normalize(url: url, apiKey: apiKey)
    }

    // Normalizes a URL by ensuring it uses the HTTPS scheme, points to the correct MapTiler API host,
    // and includes the provided API key as a query parameter if it isn't already present.
    internal static func normalize(url: URL, apiKey: String) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        // Handle custom maptiler:// scheme
        if components.scheme == "maptiler" {
            let originalHost = components.host ?? ""
            let originalPath = components.path

            components.scheme = "https"
            components.host = "api.maptiler.com"

            // Map maptiler://<host>/<path> to https://api.maptiler.com/<host>/<path>
            var newPath = "/" + originalHost
            if !originalPath.isEmpty {
                if !originalPath.hasPrefix("/") {
                    newPath += "/"
                }
                newPath += originalPath
            }
            components.path = newPath
        }

        // Ensure query parameter "key" is present
        var queryItems = components.queryItems ?? []
        if !queryItems.contains(where: { $0.name == "key" }) {
            queryItems.append(URLQueryItem(name: "key", value: apiKey))
            components.queryItems = queryItems
        }

        return components.url ?? url
    }
}
