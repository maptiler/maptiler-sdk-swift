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

    @Test("Test max attempts limit")
    func testMaxAttempts() async throws {
        let policy = MTNetworkRetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)
        var attemptCount = 0
        
        let start = Date()
        do {
            let _: String = try await policy.execute {
                attemptCount += 1
                throw MTOfflineHTTPError.timeout
            }
            Issue.record("Should have thrown an error")
        } catch {
            let elapsed = Date().timeIntervalSince(start)
            #expect(attemptCount == 3)
            #expect(error as? MTOfflineHTTPError == .timeout)
            // Delays: 0.01, 0.02 -> Total ~0.03 + jitter
            // Jitter is 0.5 to 1.5 of the value.
            // min delay = 0.005 + 0.01 = 0.015
            // max delay = 0.015 + 0.03 = 0.045
            #expect(elapsed >= 0.015)
        }
    }

    @Test("Test 429 Retry-After is respected")
    func testRetryAfter429() async throws {
        let policy = MTNetworkRetryPolicy(maxAttempts: 2, baseDelay: 0.01, maxDelay: 0.1)
        var attemptCount = 0
        
        let start = Date()
        do {
            let result: String = try await policy.execute {
                attemptCount += 1
                if attemptCount == 1 {
                    throw MTOfflineHTTPError.tooManyRequests(retryAfter: 0.2)
                }
                return "Success"
            }
            let elapsed = Date().timeIntervalSince(start)
            #expect(attemptCount == 2)
            #expect(result == "Success")
            #expect(elapsed >= 0.2) // Should sleep for at least 0.2
            #expect(elapsed < 0.6) // Should not sleep for much longer
        } catch {
            Issue.record("Should not have thrown an error: \(error)")
        }
    }
    
    @Test("Test Non-retryable error fails immediately")
    func testNonRetryableError() async throws {
        let policy = MTNetworkRetryPolicy(maxAttempts: 3, baseDelay: 0.01, maxDelay: 0.1)
        var attemptCount = 0
        
        do {
            let _: String = try await policy.execute {
                attemptCount += 1
                throw MTOfflineHTTPError.notFound
            }
            Issue.record("Should have thrown an error")
        } catch {
            #expect(attemptCount == 1)
            #expect(error as? MTOfflineHTTPError == .notFound)
        }
    }
    
    @Test("Test exponential backoff with jitter limits")
    func testExponentialBackoffJitter() async throws {
        let policy = MTNetworkRetryPolicy(maxAttempts: 3, baseDelay: 0.1, maxDelay: 1.0)
        var attemptCount = 0
        
        let start = Date()
        do {
            let _: String = try await policy.execute {
                attemptCount += 1
                if attemptCount < 3 {
                    throw MTOfflineHTTPError.serverError(500)
                }
                return "OK"
            }
            let elapsed = Date().timeIntervalSince(start)
            #expect(attemptCount == 3)
            // 1st retry delay base = 0.1 -> 0.05 to 0.15
            // 2nd retry delay base = 0.2 -> 0.1 to 0.3
            // Total sleep time = 0.15 to 0.45
            #expect(elapsed >= 0.15)
        } catch {
            Issue.record("Should not have thrown: \(error)")
        }
    }
}
