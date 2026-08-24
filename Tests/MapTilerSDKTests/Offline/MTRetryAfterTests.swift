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
        // We set maxDelay to 0.1s, but provide a Retry-After of 10s.
        // If it works correctly, it should NOT wait 10s.
        let maxDelay: TimeInterval = 0.1
        let policy = MTNetworkRetryPolicy(maxAttempts: 2, baseDelay: 0.01, maxDelay: maxDelay)
        
        let start = Date()
        do {
            let _: String = try await policy.execute {
                // Throw 429 with 10s Retry-After
                throw MTOfflineHTTPError.tooManyRequests(retryAfter: 10.0)
            }
        } catch {
            let elapsed = Date().timeIntervalSince(start)
            // If it waited 10s, elapsed would be >= 10.
            // If it respected maxDelay, elapsed should be around 0.1.
            print("Elapsed time with 10s Retry-After: \(elapsed)s")
            
            // Current behavior (likely failure): elapsed >= 10
            // Desired behavior: elapsed < 1.0 (some margin for CI)
            #expect(elapsed < 1.0, "Retry-After of 10s was not capped by maxDelay of \(maxDelay)s")
        }
    }
}
