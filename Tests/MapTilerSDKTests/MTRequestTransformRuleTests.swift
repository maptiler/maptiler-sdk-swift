//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK
import Foundation

@Suite
struct MTRequestTransformRuleTests {

    @Test
    func addQueryParametersEncoding() throws {
        let rule = MTRequestTransformRule.addQueryParameters(
            matchType: .prefix,
            matchValue: "https://api.example.com",
            parameters: ["apiKey": "secret"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(rule)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(json?["matchType"] as? String == "prefix")
        #expect(json?["matchValue"] as? String == "https://api.example.com")
        #expect(json?["actionType"] as? String == "addQueryParameters")
        
        let params = json?["queryParameters"] as? [String: String]
        #expect(params == ["apiKey": "secret"])
    }

    @Test
    func addHeadersEncoding() throws {
        let rule = MTRequestTransformRule.addHeaders(
            matchType: .regex,
            matchValue: ".*",
            headers: ["Authorization": "Bearer token"]
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(rule)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(json?["matchType"] as? String == "regex")
        #expect(json?["matchValue"] as? String == ".*")
        #expect(json?["actionType"] as? String == "addHeaders")
        
        let headers = json?["headers"] as? [String: String]
        #expect(headers == ["Authorization": "Bearer token"])
    }

    @Test
    func rewriteURLEncoding() throws {
        let rule = MTRequestTransformRule.rewriteURL(
            matchType: .prefix,
            matchValue: "http://",
            url: "https://"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(rule)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(json?["matchType"] as? String == "prefix")
        #expect(json?["matchValue"] as? String == "http://")
        #expect(json?["actionType"] as? String == "rewriteURL")
        #expect(json?["rewriteURL"] as? String == "https://")
    }

    @Test
    func setCredentialsEncoding() throws {
        let rule = MTRequestTransformRule.setCredentials(
            matchType: .regex,
            matchValue: ".*",
            credentials: "include"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(rule)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        #expect(json?["matchType"] as? String == "regex")
        #expect(json?["matchValue"] as? String == ".*")
        #expect(json?["actionType"] as? String == "setCredentials")
        #expect(json?["credentials"] as? String == "include")
    }

    @Test
    func setTransformRequestCommand() throws {
        let rule = MTRequestTransformRule.rewriteURL(
            matchType: .prefix,
            matchValue: "http://",
            url: "https://"
        )
        
        let command = SetTransformRequest(rules: [rule])
        let js = command.toJS()
        
        #expect(js.contains("setTransformRequest("))
        #expect(js.contains("createTransformRequest("))
        #expect(js.contains("rewriteURL"))
        #expect(js.contains("http:\\/\\/"))
    }
}
