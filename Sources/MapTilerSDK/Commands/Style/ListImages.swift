//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation

package struct ListImages: MTValueCommand {
    package func toJS() -> JSString {
        return "JSON.stringify(\(MTBridge.mapObject).listImages()) ?? 'null';"
    }
}
