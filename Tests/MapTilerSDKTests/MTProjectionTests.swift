//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

@Suite
struct MTProjectionTests {
    @Test func isGlobeProjectionEnabled_toJS_matchesSignature() async throws {
        let command = IsGlobeProjectionEnabled()
        #expect(command.toJS() == "map.isGlobeProjection();")
    }
}

