//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  UpdateImageInSource.swift
//  MapTilerSDK
//

import Foundation

package struct UpdateImageInSource: MTCommand {
    var source: MTSource
    var url: URL
    var coordinates: [[Double]]

    package func toJS() -> JSString {
        let sourceRef = "\(MTBridge.mapObject).getSource('\(source.identifier)')"
        let payload = "{url: '\(url.absoluteString)', coordinates: \(coordinates)}"
        return "\(sourceRef).updateImage(\(payload));"
    }
}
