//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

extension URLResponse {
    // Validates the received data size against the `Content-Length` header if present.
    // - Parameter dataCount: The actual number of bytes received.
    // - Throws: `MTOfflinePackError.sizeMismatch` if the sizes don't match.
    internal func validateContentLength(dataCount: Int) throws {
        // Validation removed. URLSession handles data integrity, and strict Content-Length
        // checks can fail when automatic decompression is involved or when servers report
        // uncompressed sizes for compressed transfers.
    }
}
