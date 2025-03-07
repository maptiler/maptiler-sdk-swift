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
        }

        return emptyReturnValue
    }

    private func handleMTVectorTileSource(_ source: MTVectorTileSource) -> JSString {
        var data: JSString = ""
        if let dataUrl = source.url {
            data = "data: '\(dataUrl.absoluteString)'"
        } else if let tiles = source.tiles {
            data = "tiles: '\(tiles)'"
        }

        var attributionString: JSString = ""
        if source.attribution != nil {
            attributionString = "attribution: '\(attributionString)'"
        }

        return """
        \(MTBridge.mapObject).addSource('\(source.identifier)', {
            type: '\(source.type)',
            minzoom: \(source.minZoom),
            maxzoom: \(source.maxZoom),
            bounds: \(source.bounds),
            scheme: \(source.scheme.rawValue),
            \(data),
            \(attributionString)
        });
        """
    }
}
