//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

internal struct MTBackgroundTaskData: Codable, Sendable {
    let taskIdentifier: Int
    let packId: String
    let relativePath: String
    let isStyle: Bool
    let resourceURL: URL
}
