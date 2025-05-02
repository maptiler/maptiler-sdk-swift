//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddLogoControl.swift
//  MapTilerSDK
//

import Foundation

package struct AddLogoControl: MTCommand {
    var name: String
    var url: URL
    var linkURL: URL
    var position: MTMapCorner

    package func toJS() -> JSString {
        let addLogoCommand = """
            const \(name) = new \(MTBridge.sdkObject).MaptilerLogoControl({
                logoURL: "\(url)",
                linkURL: "\(linkURL)"
            });
            \("\(MTBridge.mapObject).addControl(\(name), '\(position.rawValue)');")
            """

        return addLogoCommand
    }
}
