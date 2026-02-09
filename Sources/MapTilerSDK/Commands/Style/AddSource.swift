//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetSource.swift
//  MapTilerSDK
//

package struct AddSource: MTCommand {
    let emptyReturnValue = ""

    var source: MTSource

    package func toJS() -> JSString {
        if let source = source as? MTVectorTileSource {
            return handleMTVectorTileSource(source)
        } else if let source = source as? MTRasterTileSource {
            return handleMTRasterTileSource(source)
        } else if let source = source as? MTRasterDEMSource {
            return handleMTRasterDEMSource(source)
        } else if let source = source as? MTGeoJSONSource {
            return handleGeoJSONSource(source)
        } else if let source = source as? MTImageSource {
            return handleImageSource(source)
        }

        return emptyReturnValue
    }

    private func handleMTRasterTileSource(_ source: MTRasterTileSource) -> JSString {
        var data: JSString = ""
        if let dataUrl = source.url {
            data = "url: '\(dataUrl.absoluteString)'"
        } else if let tiles = source.tiles {
            data = "tiles: \(tiles.map { $0.absoluteString.removingPercentEncoding ?? "" })"
        }

        var attributionString: JSString = ""
        if let attr = source.attribution, !attr.isEmpty {
            attributionString = "attribution: '\(attr)'"
        }

        return """
        \(MTBridge.mapObject).addSource('\(source.identifier)', {
            type: '\(source.type.rawValue)',
            minzoom: \(source.minZoom),
            maxzoom: \(source.maxZoom),
            bounds: \(source.bounds),
            scheme: '\(source.scheme.rawValue)',
            tileSize: \(source.tileSize),
            \(data),
            \(attributionString)
        });
        """
    }

    private func handleMTRasterDEMSource(_ source: MTRasterDEMSource) -> JSString {
        var data: JSString = ""
        if let dataUrl = source.url {
            data = "url: '\(dataUrl.absoluteString)'"
        } else if let tiles = source.tiles {
            data = "tiles: \(tiles.map { $0.absoluteString.removingPercentEncoding ?? "" })"
        }

        var attributionString: JSString = ""
        if let attr = source.attribution, !attr.isEmpty {
            attributionString = "attribution: '\(attr)'"
        }

        return """
        \(MTBridge.mapObject).addSource('\(source.identifier)', {
            type: '\(source.type.rawValue)',
            minzoom: \(source.minZoom),
            maxzoom: \(source.maxZoom),
            bounds: \(source.bounds),
            encoding: '\(source.encoding.rawValue)',
            tileSize: \(source.tileSize),
            \(data),
            \(attributionString)
        });
        """
    }

    private func handleMTVectorTileSource(_ source: MTVectorTileSource) -> JSString {
        var data: JSString = ""
        if let dataUrl = source.url {
            data = "url: '\(dataUrl.absoluteString)'"
        } else if let tiles = source.tiles {
            data = "tiles: \(tiles.map { $0.absoluteString.removingPercentEncoding ?? "" })"
        }

        var attributionString: JSString = ""
        if source.attribution != nil {
            attributionString = "attribution: '\(attributionString)'"
        }

        return """
        \(MTBridge.mapObject).addSource('\(source.identifier)', {
            type: '\(source.type.rawValue)',
            minzoom: \(source.minZoom),
            maxzoom: \(source.maxZoom),
            bounds: \(source.bounds),
            scheme: '\(source.scheme.rawValue)',
            \(data),
            \(attributionString)
        });
        """
    }

    private func handleGeoJSONSource(_ source: MTGeoJSONSource) -> JSString {
        guard let sourceString: JSString = source.toJSON() else {
            return emptyReturnValue
        }

        var jsSourceString = sourceString

        if let url = source.url, url.isFileURL {
            jsSourceString = replaceDataString(sourceString: sourceString)
        } else if let jsonString = source.jsonString, jsonString != "" {
            jsSourceString = replaceDataString(sourceString: sourceString)
        }

        return "\(MTBridge.mapObject).addSource('\(source.identifier)', \(jsSourceString));"
    }

    private func handleImageSource(_ source: MTImageSource) -> JSString {
        guard let url = source.url else { return emptyReturnValue }
        return """
        \(MTBridge.mapObject).addSource('\(source.identifier)', {
            type: '\(source.type.rawValue)',
            url: '\(url.absoluteString)',
            coordinates: \(source.coordinates)
        });
        """
    }
}

fileprivate func replaceDataString(sourceString: String) -> String {
    let patternToReplace = #"("data":\s*)"([^"]*)""#
    let dataString = sourceString.replacingOccurrences(
        of: patternToReplace,
        with: #"$1$2"#,
        options: .regularExpression
    )

    return dataString
}
