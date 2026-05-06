//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

extension URLResponse {
    /// Validates the received data size against the `Content-Length` header if present.
    /// - Parameter dataCount: The actual number of bytes received.
    /// - Throws: `MTOfflinePackError.sizeMismatch` if the sizes don't match.
    internal func validateContentLength(dataCount: Int) throws {
        guard let httpResponse = self as? HTTPURLResponse else { return }

        // Content-Length header is case-insensitive
        if let contentLengthString = httpResponse.value(forHTTPHeaderField: "Content-Length"),
            let expectedSize = Int64(contentLengthString) {
            let actualSize = Int64(dataCount)
            if expectedSize != actualSize {
                throw MTOfflinePackError.sizeMismatch(
                    expected: expectedSize,
                    actual: actualSize
                )
            }
        }
    }
}
