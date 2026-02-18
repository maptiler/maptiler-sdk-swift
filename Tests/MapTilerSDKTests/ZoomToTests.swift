//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
@testable import MapTilerSDK

import Foundation
import CoreLocation

@Suite
struct ZoomToTests {

    @Test func zoomToCommand_shouldMatchJS() async throws {
        let zoom = 10.0
        let animationOptions = MTAnimationOptions(
            duration: 2500,
            offset: MTPoint(x: 1.5, y: 2.5),
            shouldAnimate: true,
            isEssential: false,
            easing: .cubic
        )

        let options = ZoomToOptions(zoom: zoom, animationOptions: animationOptions)
        var optionsString: JSString = options.toJSON() ?? ""
        optionsString = optionsString.replaceEasing()

        let zoomToJS = "\(MTBridge.mapObject).zoomTo(\(zoom), \(optionsString));"

        #expect(ZoomTo(zoom: zoom, animationOptions: animationOptions).toJS() == zoomToJS)
    }

    @Test func zoomToCommand_withoutOptions_shouldMatchJS() async throws {
        let zoom = 12.0
        let zoomToJS = "\(MTBridge.mapObject).zoomTo(\(zoom), {});"
        
        #expect(ZoomTo(zoom: zoom, animationOptions: nil).toJS() == zoomToJS)
    }
}
