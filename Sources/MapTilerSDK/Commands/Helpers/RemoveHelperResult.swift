//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  RemoveHelperResult.swift
//  MapTilerSDK
//

import Foundation

package struct RemoveHelperResult: MTCommand {
    var layerIds: [String]
    var sourceId: String

    package func toJS() -> JSString {
        let layersArrayStr = "['" + layerIds.joined(separator: "','") + "']"
        return """
        (() => {
            const layers = \(layersArrayStr);
            layers.forEach(id => {
                if (id && id.length > 0 && \(MTBridge.mapObject).getLayer(id)) {
                    \(MTBridge.mapObject).removeLayer(id);
                }
            });

            const sourceId = '\(sourceId)';
            if (sourceId && sourceId.length > 0 && \(MTBridge.mapObject).getSource(sourceId)) {
                \(MTBridge.mapObject).removeSource(sourceId);
            }
            return "";
        })();
        """
    }
}
