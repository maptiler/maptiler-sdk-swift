//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

package struct HasImage: MTValueCommand {
    var id: String

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).hasImage(\(encodedName()));"
    }

    private func encodedName() -> String {
        guard
            let data = try? JSONEncoder().encode(id),
            let string = String(data: data, encoding: .utf8)
        else {
            return "\"\(id)\""
        }
        return string
    }
}
