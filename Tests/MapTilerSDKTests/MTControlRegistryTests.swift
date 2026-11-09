//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Foundation
@testable import MapTilerSDK
import Testing

@Suite
struct MTControlRegistryTests {

    @Test func hasControlCommand_shouldMatchJS() async throws {
        let command = HasControl(id: "test-control")
        let expectedJS = "(window['test-control'] !== undefined && \(MTBridge.mapObject).hasControl(window['test-control']));"
        #expect(command.toJS() == expectedJS)
    }

    @Test func removeControlCommand_shouldMatchJS() async throws {
        let command = RemoveControl(id: "test-control")
        let expectedJS = """
        if (window['test-control'] !== undefined) {
            if (\(MTBridge.mapObject).hasControl(window['test-control'])) {
                \(MTBridge.mapObject).removeControl(window['test-control']);
            }
            delete window['test-control'];
        }
        """
        #expect(command.toJS() == expectedJS)
    }
}
