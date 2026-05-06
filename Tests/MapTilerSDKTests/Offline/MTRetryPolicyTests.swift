//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRetryPolicyTests.swift
//  MapTilerSDKTests
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite("MTRetryPolicy Tests")
struct MTRetryPolicyTests {

    actor Counter {
        var count = 0
        func increment() { count += 1 }
        func getCount() -> Int { count }
    }

    @Test("Test max attempts limit")
    func testMaxAttempts() async throws {
        let policy = MTNetworkRetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)
        let counter = Counter()
        
        let start = Date()
        do {
            let _: String = try await policy.execute {
                await counter.increment()
                throw MTOfflineHTTPError.timeout
            }
            Issue.record("Should have thrown an error")
        } catch {
            let elapsed = Date().timeIntervalSince(start)
            let finalCount = await counter.getCount()
            #expect(finalCount == 3)
            #expect(error as? MTOfflineHTTPError == .timeout)
            // Delays: 0.01, 0.02 -> Total ~0.03 + jitter
            // Jitter is 0.5 to 1.5 of the value.
            // min delay = 0.005 + 0.01 = 0.015
            // max delay = 0.015 + 0.03 = 0.045
            #expect(elapsed >= 0.015)
        }
    }

    @Test("Test Non-retryable error fails immediately")
    func testNonRetryableError() async throws {
        let policy = MTNetworkRetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)
        let counter = Counter()
        
        do {
            let _: String = try await policy.execute {
                await counter.increment()
                throw MTOfflineHTTPError.notFound
            }
            Issue.record("Should have thrown an error")
        } catch {
            let finalCount = await counter.getCount()
            #expect(finalCount == 1)
            #expect(error as? MTOfflineHTTPError == .notFound)
        }
    }
    
    @Test("Test exponential backoff with jitter limits")
    func testExponentialBackoffJitter() async throws {
        let policy = MTNetworkRetryPolicy(maxAttempts: 3, baseDelay: 0.1, maxDelay: 1.0)
        let counter = Counter()
        
        let start = Date()
        do {
            let _: String = try await policy.execute {
                await counter.increment()
                let currentCount = await counter.getCount()
                if currentCount < 3 {
                    throw MTOfflineHTTPError.serverError(500)
                }
                return "OK"
            }
            let elapsed = Date().timeIntervalSince(start)
            let finalCount = await counter.getCount()
            #expect(finalCount == 3)
            // 1st retry delay base = 0.1 -> 0.05 to 0.15
            // 2nd retry delay base = 0.2 -> 0.1 to 0.3
            // Total sleep time = 0.15 to 0.45
            #expect(elapsed >= 0.15)
        } catch {
            Issue.record("Should not have thrown: \(error)")
        }
    }
}
