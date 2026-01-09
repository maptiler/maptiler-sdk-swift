//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTColorRampTests.swift
//  MapTilerSDKTests
//

import XCTest
@testable import MapTilerSDK

final class MTColorRampTests: XCTestCase {
    func testColorEncodingClampsToValidRange() {
        let color = MTRGBAColor(red: 300, green: -5, blue: 127, alpha: -10)

        XCTAssertEqual(color.components, [255, 0, 127, 0])
    }

    func testOptionsEncodeToExpectedJSON() {
        let start = MTColorRampStop(value: 0, color: MTRGBAColor(red: 0, green: 0, blue: 0))
        let end = MTColorRampStop(value: 1, color: MTRGBAColor(red: 255, green: 255, blue: 255))
        let options = MTColorRampOptions(min: 0, max: 1, stops: [start, end])

        XCTAssertEqual(
            options.toJSON(),
            #"{"max":1,"min":0,"stops":[{"color":[0,0,0],"value":0},{"color":[255,255,255],"value":1}]}"#
        )
    }

    func testGetColorCommandBuildsJSONString() {
        let command = GetColorFromColorRamp(
            identifier: "cr1",
            value: 5.0,
            optionsJSON: #"{"smooth":false}"#
        )

        let js = command.toJS()
        XCTAssertTrue(js.contains("window.cr1"))
        XCTAssertTrue(js.contains("getColor(5.0"))
        XCTAssertTrue(js.contains("JSON.stringify"))
    }

    func testMTRGBAColorDecodingWithoutAlpha() throws {
        let data = Data("[10,20,30]".utf8)
        let decoded = try JSONDecoder().decode(MTRGBAColor.self, from: data)
        XCTAssertEqual(decoded.components, [10, 20, 30])
    }

    func testMTRGBAColorDecodingWithAlpha() throws {
        let data = Data("[10,20,30,128]".utf8)
        let decoded = try JSONDecoder().decode(MTRGBAColor.self, from: data)
        XCTAssertEqual(decoded.components, [10, 20, 30, 128])
    }

    func testCreateColorRampFromPresetCommand() {
        let cmd = CreateColorRampFromPreset(identifier: "cr2", preset: "TURBO")
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("ColorRampCollection.TURBO"))
        XCTAssertTrue(js.contains("window.cr2"))
    }

    func testCreateColorRampFromArrayDefinitionCommand() {
        let def = "[[0,[0,0,0]],[1,[255,255,255,128]]]"
        let cmd = CreateColorRampFromArrayDefinition(identifier: "cr3", definitionJSON: def)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("ColorRamp.fromArrayDefinition"))
        XCTAssertTrue(js.contains(def))
    }

    func testGetColorHexCommandIncludesAlphaFlag() {
        let cmd = GetColorHexFromColorRamp(identifier: "cr4", value: 1.0, optionsJSON: #"{"smooth":true,"withAlpha":true}"#)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("getColorHex(1.0"))
        XCTAssertTrue(js.contains("withAlpha\":true"))
    }

    func testGetColorRelativeCommandSerialization() {
        let cmd = GetColorRelativeFromColorRamp(identifier: "cr5", value: 0.5, optionsJSON: #"{"smooth":false}"#)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("getColorRelative(0.5"))
    }

    func testCloneCommandSerialization() {
        let cmd = CloneColorRamp(sourceIdentifier: "crA", targetIdentifier: "crB")
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("window.crA"))
        XCTAssertTrue(js.contains("window.crB"))
        XCTAssertTrue(js.contains("clone()"))
    }

    func testReverseCommandSerialization() {
        let cmd = ReverseColorRamp(sourceIdentifier: "crA", targetIdentifier: "crA", clone: false)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("reverse({ clone: false })"))
    }

    func testScaleCommandSerialization() {
        let cmd = ScaleColorRamp(sourceIdentifier: "crA", targetIdentifier: "crB", min: -10, max: 42, clone: true)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("scale(-10.0, 42.0, { clone: true })"))
    }

    func testSetStopsCommandSerialization() {
        let stopsJSON = "[{\"value\":0,\"color\":[0,0,0]}]"
        let cmd = SetStopsOnColorRamp(sourceIdentifier: "crA", targetIdentifier: "crB", stopsJSON: stopsJSON, clone: true)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("const stops = \(stopsJSON)"))
        XCTAssertTrue(js.contains("setStops(stops, { clone: true })"))
    }

    func testResampleCommandSerialization() {
        let cmd = ResampleColorRamp(sourceIdentifier: "crA", targetIdentifier: "crB", method: "ease-out-sqrt", samples: 17)
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("resample(\"ease-out-sqrt\", 17)"))
    }

    func testTransparentStartCommandSerialization() {
        let cmd = TransparentStartColorRamp(sourceIdentifier: "crA", targetIdentifier: "crB")
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("transparentStart()"))
    }

    func testHasTransparentStartGetterSerialization() {
        let cmd = HasTransparentStartColorRamp(identifier: "crZ")
        let js = cmd.toJS()
        XCTAssertTrue(js.contains("hasTransparentStart()"))
    }

    func testPresetCountMatchesJSCollection() {
        // Keep parity with JS ColorRampCollection constants (update when presets change)
        XCTAssertEqual(MTColorRampPreset.allCases.count, 49)
        XCTAssertTrue(MTColorRampPreset.allCases.contains(.turbo))
        XCTAssertTrue(MTColorRampPreset.allCases.contains(.magma))
    }
}
