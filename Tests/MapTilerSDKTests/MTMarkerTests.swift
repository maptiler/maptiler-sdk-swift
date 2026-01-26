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

        marker.rotation = 30.0
        marker.rotationAlignment = .map
        marker.pitchAlignment = .viewport
        marker.scale = 1.25
        marker.subpixelPositioning = false

        let jsString = AddMarker(marker: marker).toJS()

        #expect(jsString.contains("anchor: '\(marker.anchor.rawValue)'"))
        #expect(jsString.contains("offset: [\(marker.offset), \(marker.offset)]"))
        #expect(jsString.contains("scale: \(marker.scale)"))
        #expect(jsString.contains("subpixelPositioning: \(marker.subpixelPositioning)"))
        #expect(jsString.contains("opacity: \(marker.opacity)"))
        #expect(jsString.contains("opacityWhenCovered: \(marker.opacityWhenCovered)"))
        #expect(jsString.contains("rotation: \(marker.rotation)"))
        #expect(jsString.contains("rotationAlignment: '\(marker.rotationAlignment.rawValue)'"))
        #expect(jsString.contains("pitchAlignment: '\(marker.pitchAlignment.rawValue)'"))
    }

    @Test func addMarkerCommand_registersDragEvents() async throws {
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

        #expect(jsString.contains("id: '\(marker.identifier)'"))
        #expect(jsString.contains("postDragEvent_\(marker.identifier)('drag')"))
        #expect(jsString.contains("postDragEvent_\(marker.identifier)('dragstart')"))
        #expect(jsString.contains("postDragEvent_\(marker.identifier)('dragend')"))
        #expect(jsString.contains("event: 'dragstart'"))
        #expect(jsString.contains("event: 'dragend'"))
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
        markers[0].rotation = 10.0
        markers[0].rotationAlignment = .map
        markers[0].pitchAlignment = .map
        markers[0].scale = 0.75
        markers[0].subpixelPositioning = true
        markers[1].opacity = 0.7
        markers[1].opacityWhenCovered = 0.4
        markers[1].rotation = 20.0
        markers[1].rotationAlignment = .viewport
        markers[1].pitchAlignment = .auto
        markers[1].scale = 1.5
        markers[1].subpixelPositioning = false

        let jsString = AddMarkers(markers: markers, withSingleIcon: image).toJS()

        for marker in markers {
            #expect(jsString.contains("anchor: '\(marker.anchor.rawValue)'"))
            #expect(jsString.contains("offset: [\(marker.offset), \(marker.offset)]"))
            #expect(jsString.contains("scale: \(marker.scale)"))
            #expect(jsString.contains("subpixelPositioning: \(marker.subpixelPositioning)"))
            #expect(jsString.contains("opacity: \(marker.opacity)"))
            #expect(jsString.contains("opacityWhenCovered: \(marker.opacityWhenCovered)"))
            #expect(jsString.contains("rotation: \(marker.rotation)"))
            #expect(jsString.contains("rotationAlignment: '\(marker.rotationAlignment.rawValue)'"))
            #expect(jsString.contains("pitchAlignment: '\(marker.pitchAlignment.rawValue)'"))
            #expect(jsString.contains("postDragEvent_\(marker.identifier)('dragstart')"))
            #expect(jsString.contains("postDragEvent_\(marker.identifier)('dragend')"))
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
        markers[0].rotation = 15.0
        markers[0].rotationAlignment = .auto
        markers[0].pitchAlignment = .viewport
        markers[0].scale = 1.1
        markers[0].subpixelPositioning = true
        markers[1].opacity = 0.8
        markers[1].opacityWhenCovered = 0.45
        markers[1].rotation = 25.0
        markers[1].rotationAlignment = .map
        markers[1].pitchAlignment = .map
        markers[1].scale = 0.9
        markers[1].subpixelPositioning = false

        let jsString = AddMarkers(markers: markers, withSingleIcon: nil).toJS()

        for marker in markers {
            #expect(jsString.contains("anchor: '\(marker.anchor.rawValue)'"))
            #expect(jsString.contains("offset: [\(marker.offset), \(marker.offset)]"))
            #expect(jsString.contains("scale: \(marker.scale)"))
            #expect(jsString.contains("subpixelPositioning: \(marker.subpixelPositioning)"))
            #expect(jsString.contains("opacity: \(marker.opacity)"))
            #expect(jsString.contains("opacityWhenCovered: \(marker.opacityWhenCovered)"))
            #expect(jsString.contains("rotation: \(marker.rotation)"))
            #expect(jsString.contains("rotationAlignment: '\(marker.rotationAlignment.rawValue)'"))
            #expect(jsString.contains("pitchAlignment: '\(marker.pitchAlignment.rawValue)'"))
            #expect(jsString.contains("postDragEvent_\(marker.identifier)('dragstart')"))
            #expect(jsString.contains("postDragEvent_\(marker.identifier)('dragend')"))
        }
    }

    @Test func markerGetterCommands_matchExpectedJS() async throws {
        let marker = MTMarker(coordinates: coordinate, draggable: true, anchor: .top, offset: 5.0)

        #expect(GetMarkerCoordinates(marker: marker).toJS() == "(() => {\n    const p = window.\(marker.identifier).getLngLat();\n    return p ? { lat: p.lat, lng: p.lng } : null;\n})();")
        #expect(GetMarkerPitchAlignment(marker: marker).toJS() == "window.\(marker.identifier).getPitchAlignment();")
        #expect(GetMarkerRotation(marker: marker).toJS() == "window.\(marker.identifier).getRotation();")
        #expect(GetMarkerRotationAlignment(marker: marker).toJS() == "window.\(marker.identifier).getRotationAlignment();")
        #expect(GetMarkerOffset(marker: marker).toJS() == "window.\(marker.identifier).getOffset().x;")
        #expect(IsMarkerDraggable(marker: marker).toJS() == "window.\(marker.identifier).isDraggable();")
    }

    @Test func markerSetterCommands_matchExpectedJS() async throws {
        let marker = MTMarker(coordinates: coordinate, draggable: true, anchor: .top, offset: 5.0)

        let draggableJS = SetMarkerDraggable(marker: marker, draggable: false).toJS()
        let offsetJS = SetMarkerOffset(marker: marker, offset: 12.0).toJS()
        let rotationJS = SetMarkerRotation(marker: marker, rotation: 15.5).toJS()
        let alignmentJS = SetMarkerRotationAlignment(marker: marker, alignment: .map).toJS()
        let togglePopupJS = ToggleMarkerPopup(marker: marker).toJS()

        #expect(draggableJS == "window.\(marker.identifier).setDraggable(false);")
        #expect(offsetJS == "window.\(marker.identifier).setOffset([12.0, 12.0]);")
        #expect(rotationJS == "window.\(marker.identifier).setRotation(15.5);")
        #expect(alignmentJS == "window.\(marker.identifier).setRotationAlignment('\(MTMarkerRotationAlignment.map.rawValue)');")
        #expect(togglePopupJS == "window.\(marker.identifier).togglePopup();")
    }
}
