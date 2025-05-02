//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  SetGlyphs.swift
//  MapTilerSDK
//

import Foundation

package struct SetGlyphs: MTCommand {
    var url: URL
    var options: MTStyleSetterOptions?

    package func toJS() -> JSString {
        let path = url.absoluteString
        let absoluteURLString = path.removingPercentEncoding ?? path
        let stringWithOptions = "'\(absoluteURLString)',\(options.toJSON() ?? "")"
        let parameters: JSString = options != nil ? stringWithOptions : "'\(absoluteURLString)'"

        return "\(MTBridge.mapObject).setGlyphs(\(parameters));"
    }
}
