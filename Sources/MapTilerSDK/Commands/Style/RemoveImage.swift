//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

package struct RemoveImage: MTCommand {
    var name: String

    package func toJS() -> JSString {
        return "\(MTBridge.mapObject).style.removeImage(\(encodedName()));"
    }

    private func encodedName() -> String {
        guard
            let data = try? JSONEncoder().encode(name),
            let string = String(data: data, encoding: .utf8)
        else {
            return "\"\(name)\""
        }
        return string
    }
}
