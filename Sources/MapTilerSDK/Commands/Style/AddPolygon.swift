//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  AddPolygon.swift
//  MapTilerSDK
//

import Foundation

package struct AddPolygon: MTCommand {
    let emptyReturnValue = ""

    var dataString: String?
    var dataURL: URL?
    var fillOpacity: Double?
    var fillColorHex: String?

    init(data: String, fillOpacity: Double? = nil, fillColorHex: String? = nil) {
        self.dataString = data
        self.fillOpacity = fillOpacity
        self.fillColorHex = fillColorHex
    }

    init(url: URL, fillOpacity: Double? = nil, fillColorHex: String? = nil) {
        self.dataURL = url
        self.fillOpacity = fillOpacity
        self.fillColorHex = fillColorHex
    }

    package func toJS() -> JSString {
        let fillOpacityJS = "\(fillOpacity ?? 1.0)"
        let dataJS = getDataJS()

        var colorProp: JSString = ""
        if let fillColorHex, !fillColorHex.isEmpty {
            colorProp = ", fillColor: '\(fillColorHex)'"
        }

        return "maptilersdk.helpers.addPolygon(\(MTBridge.mapObject), { data: \(dataJS), fillOpacity: \(fillOpacityJS)\(colorProp) });"
    }

    private func getDataJS() -> JSString {
        if let dataString {
            // Treat as literal string path/identifier
            return "'\(escapeSingleQuotes(dataString))'"
        }

        if let dataURL {
            if dataURL.isFileURL {
                // Embed local file contents as parsed JSON
                if let data = try? Data(contentsOf: dataURL) {
                    let base64 = data.base64EncodedString()
                    return "JSON.parse(atob('\(base64)'))"
                }
            }

            // For remote or non-file URLs, pass as string
            return "'\(escapeSingleQuotes(dataURL.absoluteString))'"
        }

        return "''"
    }

    private func escapeSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "\\'")
    }
}
