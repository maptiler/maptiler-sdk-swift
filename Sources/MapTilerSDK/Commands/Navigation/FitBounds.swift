//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  FitBounds.swift
//  MapTilerSDK
//

package struct FitBounds: MTCommand {
    var bounds: MTBounds
    var options: MTFitBoundsOptions?

    package func toJS() -> JSString {
        let boundsString: JSString = bounds.toJSON() ?? "[]"
        var optionsArgument = ""

        if let options {
            var optionsString: JSString = options.toJSON() ?? ""
            optionsString = optionsString.replaceEasing()
            optionsArgument = ", \(optionsString)"
        }

        return "\(MTBridge.mapObject).fitBounds(\(boundsString)\(optionsArgument));"
    }
}
