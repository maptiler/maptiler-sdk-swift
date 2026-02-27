//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  FitScreenCoordinates.swift
//  MapTilerSDK
//

package struct FitScreenCoordinates: MTCommand {
    var p0: MTPoint
    var p1: MTPoint
    var bearing: Double
    var options: MTFitBoundsOptions?

    package func toJS() -> JSString {
        let p0String = "[\(p0.x), \(p0.y)]"
        let p1String = "[\(p1.x), \(p1.y)]"
        var optionsArgument = ""

        if let options {
            var optionsString: JSString = options.toJSON() ?? ""
            optionsString = optionsString.replaceEasing()
            optionsArgument = ", \(optionsString)"
        }

        return "\(MTBridge.mapObject).fitScreenCoordinates(\(p0String), \(p1String), \(bearing)\(optionsArgument));"
    }
}
