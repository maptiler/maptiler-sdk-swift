//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTColorRampAdditionalTests.swift
//  MapTilerSDKTests
//

import XCTest
@testable import MapTilerSDK

final class MTColorRampAdditionalTests: XCTestCase {
    func testArrayStopEncodingProducesExpectedJSONArray() throws {
        let stop = MTColorRampArrayStop(value: 42.5, color: MTRGBAColor(red: 1, green: 2, blue: 3, alpha: 4))
        let json = stop.toJSON()
        XCTAssertEqual(json, "[42.5,[1,2,3,4]]")
    }

    func testColorEncodingOmitAlphaWhenOpaque() throws {
        // Explicit alpha in initializer is preserved (even if 255)
        let c1 = MTRGBAColor(red: 10, green: 20, blue: 30, alpha: 255)
        // No alpha specified means 3 components
        let c2 = MTRGBAColor(red: 10, green: 20, blue: 30)

        XCTAssertEqual(c1.components, [10, 20, 30, 255])
        XCTAssertEqual(c2.components, [10, 20, 30])
    }

    func testOptionsEncodingWithAlphaStop() throws {
        let s1 = MTColorRampStop(value: 0, color: MTRGBAColor(red: 0, green: 0, blue: 0))
        let s2 = MTColorRampStop(value: 1, color: MTRGBAColor(red: 255, green: 255, blue: 255, alpha: 128))
        let options = MTColorRampOptions(min: 0, max: 1, stops: [s1, s2])

        XCTAssertEqual(
            options.toJSON(),
            #"{"max":1,"min":0,"stops":[{"color":[0,0,0],"value":0},{"color":[255,255,255,128],"value":1}]}"#
        )
    }

    func testCreateColorRampFromPresetCommand() {
        let cmd = CreateColorRampFromPreset(identifier: "crX", preset: MTColorRampPreset.turbo.rawValue)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("window.crX"))
        XCTAssertTrue(js.contains("ColorRampCollection.TURBO"))
        XCTAssertTrue(js.contains("clone()"))
    }

    func testCreateColorRampFromArrayDefinitionCommand() {
        let def: [MTColorRampArrayStop] = [
            .init(value: 0, color: MTRGBAColor(red: 0, green: 0, blue: 0)),
            .init(value: 1, color: MTRGBAColor(red: 255, green: 255, blue: 255))
        ]
        let json = def.toJSON()!
        let cmd = CreateColorRampFromArrayDefinition(identifier: "crY", definitionJSON: json)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("window.crY"))
        XCTAssertTrue(js.contains("ColorRamp.fromArrayDefinition"))
        XCTAssertTrue(js.contains("[[0,[0,0,0]],[1,[255,255,255]]]"))
    }

    func testGetColorHexOptionsIncludeAlphaFlag() throws {
        // Ensure the options JSON embeds withAlpha when requested by Swift API
        let cmd = GetColorHexFromColorRamp(identifier: "cr1", value: 5.0, optionsJSON: "{\"smooth\": true, \"withAlpha\": true}")
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("getColorHex(5.0"))
        XCTAssertTrue(js.contains("withAlpha"))
        XCTAssertTrue(js.contains("true"))
    }

    func testResampleCommandIncludesMethodAndSamples() {
        let cmd = ResampleColorRamp(
            sourceIdentifier: "crIn",
            targetIdentifier: "crOut",
            method: MTColorRampResampleMethod.easeOutSqrt.rawValue,
            samples: 17
        )
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("window.crIn"))
        XCTAssertTrue(js.contains("resample(\"ease-out-sqrt\", 17)"))
        XCTAssertTrue(js.contains("window.crOut"))
    }

    func testHasTransparentStartCommandBooleanResult() {
        let cmd = HasTransparentStartColorRamp(identifier: "crA")
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("window.crA"))
        XCTAssertTrue(js.contains("!!(")) // coerces to boolean
    }

    @MainActor
    func testGeneratedIdentifierPrefix() {
        let options = MTColorRampOptions(stops: [
            .init(value: 0, color: MTRGBAColor(red: 0, green: 0, blue: 0)),
            .init(value: 1, color: MTRGBAColor(red: 255, green: 255, blue: 255))
        ])
        let ramp = MTColorRamp(options: options)
        XCTAssertTrue(ramp.identifier.hasPrefix("colorRamp"))
    }
}
