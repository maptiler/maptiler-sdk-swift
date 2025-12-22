//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

import CoreLocation

@Suite
struct MTTextPopupTests {
    let coordinate = CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0)

    @Test func addTextPopupCommand_includesMaxWidthWhenProvided() async throws {
        let popup = MTTextPopup(
            coordinates: coordinate,
            text: "Hello World",
            offset: 4.0,
            maxWidth: 320.0
        )

        let jsString = AddTextPopup(popup: popup).toJS()

        #expect(jsString.contains("\"offset\":4"))
        #expect(jsString.contains("\"maxWidth\":320"))
    }

    @Test func addTextPopupCommand_omitsMaxWidthWhenNil() async throws {
        let popup = MTTextPopup(
            coordinates: coordinate,
            text: "Hello World",
            offset: 2.0
        )

        let jsString = AddTextPopup(popup: popup).toJS()

        #expect(!jsString.contains("maxWidth"))
    }

    @Test func textPopupGetterCommands_matchExpectedJS() async throws {
        let popup = MTTextPopup(coordinates: coordinate, text: "Hello World")

        #expect(GetTextPopupCoordinates(popup: popup).toJS() == "\(popup.identifier).getLngLat();")
        #expect(IsTextPopupOpen(popup: popup).toJS() == "\(popup.identifier).isOpen();")
    }
}
