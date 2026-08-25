//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRetryAfterTests.swift
//  MapTilerSDKTests
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("MTRetryAfter Tests")
struct MTRetryAfterTests {

    @Test("Test Retry-After respects maxDelay")
    func testRetryAfterRespectsMaxDelay() async throws {
        // We set maxDelay to 0.1s, but provide a Retry-After of 30s.
        // If it works correctly, it should NOT wait 30s.
        let maxDelay: TimeInterval = 0.1
        let policy = MTNetworkRetryPolicy(maxAttempts: 2, baseDelay: 0.01, maxDelay: maxDelay)
        
        let start = Date()
        do {
            let _: String = try await policy.execute {
                // Throw 429 with 30s Retry-After
                throw MTOfflineHTTPError.tooManyRequests(retryAfter: 30.0)
            }
        } catch {
            let elapsed = Date().timeIntervalSince(start)
            // If it waited 30s, elapsed would be >= 30.
            // If it respected maxDelay, elapsed should be around 0.1.
            print("Elapsed time with 30s Retry-After: \(elapsed)s")
            
            // On a busy CI, elapsed can be a few seconds, but should be well under 30s
            #expect(elapsed < 15.0, "Retry-After of 30s was not capped by maxDelay of \(maxDelay)s")
        }
    }
}
