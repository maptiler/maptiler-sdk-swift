//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTRequestTransformRule.swift
//  MapTilerSDK
//

import Foundation

/// A rule to declaratively transform network requests made by the map.
public struct MTRequestTransformRule: Codable, Sendable, Equatable {
    /// Defines how the URL should be matched.
    public enum MatchType: String, Codable, Sendable, Equatable {
        /// Matches if the URL starts with the specified value.
        case prefix
        /// Matches if the URL matches the specified regular expression.
        case regex
    }

    /// Defines the action to take when a match is found.
    public enum ActionType: String, Codable, Sendable, Equatable {
        /// Adds or replaces query parameters.
        case addQueryParameters
        /// Adds HTTP headers.
        case addHeaders
        /// Rewrites the matched portion of the URL.
        case rewriteURL
        /// Sets request credentials.
        case setCredentials
    }

    public let matchType: MatchType
    public let matchValue: String
    public let actionType: ActionType

    public let queryParameters: [String: String]?
    public let headers: [String: String]?
    public let rewriteURL: String?
    public let credentials: String?

    public init(
        matchType: MatchType,
        matchValue: String,
        actionType: ActionType,
        queryParameters: [String: String]? = nil,
        headers: [String: String]? = nil,
        rewriteURL: String? = nil,
        credentials: String? = nil
    ) {
        self.matchType = matchType
        self.matchValue = matchValue
        self.actionType = actionType
        self.queryParameters = queryParameters
        self.headers = headers
        self.rewriteURL = rewriteURL
        self.credentials = credentials
    }

    /// Creates a rule that adds query parameters to a matched URL.
    public static func addQueryParameters(
        matchType: MatchType,
        matchValue: String,
        parameters: [String: String]
    ) -> MTRequestTransformRule {
        return MTRequestTransformRule(
            matchType: matchType,
            matchValue: matchValue,
            actionType: .addQueryParameters,
            queryParameters: parameters
        )
    }

    /// Creates a rule that adds HTTP headers to a matched URL request.
    public static func addHeaders(
        matchType: MatchType,
        matchValue: String,
        headers: [String: String]
    ) -> MTRequestTransformRule {
        return MTRequestTransformRule(
            matchType: matchType,
            matchValue: matchValue,
            actionType: .addHeaders,
            headers: headers
        )
    }

    /// Creates a rule that rewrites the matched portion of the URL.
    public static func rewriteURL(
        matchType: MatchType,
        matchValue: String,
        url: String
    ) -> MTRequestTransformRule {
        return MTRequestTransformRule(
            matchType: matchType,
            matchValue: matchValue,
            actionType: .rewriteURL,
            rewriteURL: url
        )
    }

    /// Creates a rule that sets the credentials mode for a matched URL request.
    public static func setCredentials(
        matchType: MatchType,
        matchValue: String,
        credentials: String
    ) -> MTRequestTransformRule {
        return MTRequestTransformRule(
            matchType: matchType,
            matchValue: matchValue,
            actionType: .setCredentials,
            credentials: credentials
        )
    }
}
