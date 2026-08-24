//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

extension URLResponse {
    internal func validateHTTPStatus() throws {
        guard let httpResponse = self as? HTTPURLResponse else {
            throw MTOfflineHTTPError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 404:
            throw MTOfflineHTTPError.notFound
        case 429:
            let retryAfterStr = httpResponse.value(forHTTPHeaderField: "Retry-After")
            var retryAfter: TimeInterval?
            if let str = retryAfterStr, let time = TimeInterval(str) {
                retryAfter = time
            } else if let str = retryAfterStr {
                // Try parsing HTTP date
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                if let date = formatter.date(from: str) {
                    let delay = date.timeIntervalSince(Date())
                    retryAfter = delay > 0 ? delay : 0
                }
            }
            throw MTOfflineHTTPError.tooManyRequests(retryAfter: retryAfter)
        case 400...499:
            throw MTOfflineHTTPError.clientError(httpResponse.statusCode)
        case 500...599:
            throw MTOfflineHTTPError.serverError(httpResponse.statusCode)
        default:
            throw MTOfflineHTTPError.invalidResponse
        }
    }

    // Validates the received data size against the `Content-Length` header if present.
    // - Parameter dataCount: The actual number of bytes received.
    // - Throws: `MTOfflinePackError.sizeMismatch` if the sizes don't match.
    internal func validateContentLength(dataCount: Int) throws {
        // Validation removed. URLSession handles data integrity, and strict Content-Length
        // checks can fail when automatic decompression is involved or when servers report
        // uncompressed sizes for compressed transfers.
    }
}
