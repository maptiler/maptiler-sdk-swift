//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

import CoreLocation
import UIKit

@Suite
struct MTMarkerTests {
    let coordinate = CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0)

    @Test func addMarkerCommand_includesAnchorAndOffset() async throws {
        let marker = MTMarker(
            coordinates: coordinate,
            color: .red,
            icon: nil,
            draggable: true,
            anchor: .bottomLeft,
            offset: 8.0,
            opacity: 0.6,
            opacityWhenCovered: 0.3
        )

        let jsString = AddMarker(marker: marker).toJS()

        #expect(jsString.contains("anchor: '\(marker.anchor.rawValue)'"))
        #expect(jsString.contains("offset: [\(marker.offset), \(marker.offset)]"))
        #expect(jsString.contains("opacity: \(marker.opacity)"))
        #expect(jsString.contains("opacityWhenCovered: \(marker.opacityWhenCovered)"))
    }

    @Test func addMarkersCommand_includesAnchorAndOffsetForSharedIcon() async throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2))
        let image = renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }

        let markers = [
            MTMarker(coordinates: coordinate, anchor: .top, offset: 4.0),
            MTMarker(
                coordinates: CLLocationCoordinate2D(latitude: 11.0, longitude: 21.0),
                anchor: .bottom,
                offset: 6.0
            )
        ]

        markers[0].opacity = 0.5
        markers[0].opacityWhenCovered = 0.25
        markers[1].opacity = 0.7
        markers[1].opacityWhenCovered = 0.4

        let jsString = AddMarkers(markers: markers, withSingleIcon: image).toJS()

        for marker in markers {
            #expect(jsString.contains("anchor: '\(marker.anchor.rawValue)'"))
            #expect(jsString.contains("offset: [\(marker.offset), \(marker.offset)]"))
            #expect(jsString.contains("opacity: \(marker.opacity)"))
            #expect(jsString.contains("opacityWhenCovered: \(marker.opacityWhenCovered)"))
        }
    }

    @Test func addMarkersCommand_includesAnchorAndOffsetForIndividualIcons() async throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 3, height: 3))
        let icon = renderer.image { context in
            UIColor.green.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 3, height: 3))
        }

        var markers = [
            MTMarker(coordinates: coordinate, anchor: .left, offset: 2.0),
            MTMarker(
                coordinates: CLLocationCoordinate2D(latitude: 12.0, longitude: 22.0),
                anchor: .right,
                offset: 3.0
            )
        ]

        markers[0].icon = icon
        markers[1].icon = icon
        markers[0].opacity = 0.55
        markers[0].opacityWhenCovered = 0.35
        markers[1].opacity = 0.8
        markers[1].opacityWhenCovered = 0.45

        let jsString = AddMarkers(markers: markers, withSingleIcon: nil).toJS()

        for marker in markers {
            #expect(jsString.contains("anchor: '\(marker.anchor.rawValue)'"))
            #expect(jsString.contains("offset: [\(marker.offset), \(marker.offset)]"))
            #expect(jsString.contains("opacity: \(marker.opacity)"))
            #expect(jsString.contains("opacityWhenCovered: \(marker.opacityWhenCovered)"))
        }
    }
}
