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

        #expect(
            GetTextPopupCoordinates(popup: popup).toJS() == """
            (() => {
                const p = window.\(popup.identifier).getLngLat();
                return p ? { lat: p.lat, lng: p.lng } : null;
            })();
            """
        )
        #expect(IsTextPopupOpen(popup: popup).toJS() == "window.\(popup.identifier).isOpen();")
    }

    @Test func textPopupLifecycleCommands_matchExpectedJS() async throws {
        let popup = MTTextPopup(coordinates: coordinate, text: "Hello World")

        #expect(OpenTextPopup(popup: popup).toJS() == "window.\(popup.identifier).addTo(\(MTBridge.mapObject));")
        #expect(CloseTextPopup(popup: popup).toJS() == "window.\(popup.identifier).remove();")
    }

    @Test func textPopupSetterCommands_matchExpectedJS() async throws {
        let popup = MTTextPopup(coordinates: coordinate, text: "O'Brien")

        #expect(SetCoordinatesToTextPopup(popup: popup).toJS() == "window.\(popup.identifier).setLngLat([20.0, 10.0]);")
        #expect(SetMaxWidthToTextPopup(popup: popup, maxWidth: 240).toJS() == "window.\(popup.identifier).setMaxWidth(240.0);")
        #expect(SetOffsetToTextPopup(popup: popup, offset: 8).toJS() == "window.\(popup.identifier).setOffset(8.0);")
        #expect(
            SetSubpixelPositioningToTextPopup(popup: popup, isEnabled: true).toJS()
                == "window.\(popup.identifier).setSubpixelPositioning(true);"
        )
        #expect(
            SetTextToTextPopup(popup: popup, text: popup.text).toJS()
                == "window.\(popup.identifier).setText('O\\'Brien');"
        )
        #expect(TrackTextPopupPointer(popup: popup).toJS() == "window.\(popup.identifier).trackPointer();")
    }
}
