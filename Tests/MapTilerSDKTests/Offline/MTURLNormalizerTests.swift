//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import Foundation
@testable import MapTilerSDK

@Suite
struct MTURLNormalizerTests {
    
    @Test func testNormalURLWithoutKey() {
        let url = URL(string: "https://api.maptiler.com/maps/streets-v2/style.json")!
        let normalized = MTURLNormalizer.normalize(url: url, apiKey: "MY_KEY")
        #expect(normalized.absoluteString == "https://api.maptiler.com/maps/streets-v2/style.json?key=MY_KEY")
    }

    @Test func testNormalURLWithKey() {
        let url = URL(string: "https://api.maptiler.com/maps/streets-v2/style.json?key=EXISTING_KEY")!
        let normalized = MTURLNormalizer.normalize(url: url, apiKey: "MY_KEY")
        #expect(normalized.absoluteString == "https://api.maptiler.com/maps/streets-v2/style.json?key=EXISTING_KEY")
    }

    @Test func testMaptilerSchemeWithoutKey() {
        let url = URL(string: "maptiler://maps/streets-v2/style.json")!
        let normalized = MTURLNormalizer.normalize(url: url, apiKey: "MY_KEY")
        #expect(normalized.absoluteString == "https://api.maptiler.com/maps/streets-v2/style.json?key=MY_KEY")
    }

    @Test func testMaptilerSchemeWithKey() {
        let url = URL(string: "maptiler://maps/streets-v2/style.json?key=EXISTING_KEY")!
        let normalized = MTURLNormalizer.normalize(url: url, apiKey: "MY_KEY")
        #expect(normalized.absoluteString == "https://api.maptiler.com/maps/streets-v2/style.json?key=EXISTING_KEY")
    }

    @Test func testURLWithOtherQueryParametersWithoutKey() {
        let url = URL(string: "https://api.maptiler.com/tiles/v3/tiles.json?foo=bar")!
        let normalized = MTURLNormalizer.normalize(url: url, apiKey: "MY_KEY")
        
        let components = URLComponents(url: normalized, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.contains(where: { $0.name == "key" && $0.value == "MY_KEY" }) == true)
        #expect(components?.queryItems?.contains(where: { $0.name == "foo" && $0.value == "bar" }) == true)
    }
    
    @Test func testURLWithOtherQueryParametersWithKey() {
        let url = URL(string: "https://api.maptiler.com/tiles/v3/tiles.json?foo=bar&key=OLD_KEY")!
        let normalized = MTURLNormalizer.normalize(url: url, apiKey: "MY_KEY")
        
        let components = URLComponents(url: normalized, resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.contains(where: { $0.name == "key" && $0.value == "OLD_KEY" }) == true)
        #expect(components?.queryItems?.contains(where: { $0.name == "key" && $0.value == "MY_KEY" }) == false)
        #expect(components?.queryItems?.contains(where: { $0.name == "foo" && $0.value == "bar" }) == true)
    }
    
    @Test func testMalformedURLFallback() {
        // Just checking that an empty path works too
        let url = URL(string: "maptiler://")!
        let normalized = MTURLNormalizer.normalize(url: url, apiKey: "MY_KEY")
        #expect(normalized.absoluteString == "https://api.maptiler.com/?key=MY_KEY")
    }

    @Test func testAsyncNormalizeWithConfig() async {
        let key = "CONFIG_KEY"
        await MTConfig.shared.setAPIKey(key)
        
        let url = URL(string: "maptiler://maps/streets-v2/style.json")!
        let normalized = await MTURLNormalizer.normalize(url: url)
        
        #expect(normalized.absoluteString == "https://api.maptiler.com/maps/streets-v2/style.json?key=\(key)")
    }
}
