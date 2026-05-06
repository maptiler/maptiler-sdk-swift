//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRetryPolicy.swift
//  MapTilerSDK
//

import Foundation

internal protocol MTRetryPolicy {
    func execute<T>(operation: @escaping @Sendable () async throws -> T) async throws -> T
}

internal struct MTNetworkRetryPolicy: MTRetryPolicy {
    let maxAttempts: Int
    let baseDelay: TimeInterval
    let maxDelay: TimeInterval

    init(maxAttempts: Int = 3, baseDelay: TimeInterval = 1.0, maxDelay: TimeInterval = 60.0) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
    }

    func execute<T>(operation: @escaping @Sendable () async throws -> T) async throws -> T {
        var attempt = 1
        while true {
            do {
                return try await operation()
            } catch {
                if attempt >= maxAttempts {
                    throw error
                }

                if !isRetryable(error: error) {
                    throw error
                }

                let delay: TimeInterval
                if let httpError = error as? MTOfflineHTTPError,
                    case .tooManyRequests(let retryAfter) = httpError,
                    let providedDelay = retryAfter {
                    delay = providedDelay
                } else {
                    // Exponential backoff: baseDelay * 2^(attempt - 1)
                    let exponentialDelay = baseDelay * pow(2.0, Double(attempt - 1))
                    let maxAllowedDelay = min(exponentialDelay, maxDelay)
                    // Jitter: random value between 0.5 * delay and 1.5 * delay
                    let jitterRange = (maxAllowedDelay * 0.5)...(maxAllowedDelay * 1.5)
                    delay = Double.random(in: jitterRange)
                }

                let nanoseconds = UInt64(delay * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanoseconds)

                attempt += 1
            }
        }
    }

    private func isRetryable(error: Error) -> Bool {
        if let packError = error as? MTOfflinePackError {
            switch packError {
            case .networkError, .serverError, .rateLimitExceeded, .sizeMismatch:
                return true
            default:
                return false
            }
        }

        if let httpError = error as? MTOfflineHTTPError {
            switch httpError {
            case .timeout, .offline, .networkError, .serverError, .tooManyRequests:
                return true
            case .invalidURL, .invalidResponse, .notFound, .clientError, .unknown:
                return false
            }
        }
        // For generic URLError
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
                return true
            default:
                return true
            }
        }
        return true
    }
}
