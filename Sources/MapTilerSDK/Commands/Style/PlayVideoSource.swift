//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  PlayVideoSource.swift
//  MapTilerSDK
//

import Foundation

package struct PlayVideoSource: MTCommand {
    var source: MTSource

    package func toJS() -> JSString {
        return """
        (function(){
            const src = \(MTBridge.mapObject).getSource('\(source.identifier)');
            if (!src) { return; }
            // Try to get the underlying HTMLVideoElement used by the VideoSource
            const v = src._video || (typeof src.getVideo === 'function' ? src.getVideo() : null);
            if (v) {
                try {
                    v.setAttribute('playsinline', '');
                    v.setAttribute('webkit-playsinline', '');
                    v.playsInline = true;
                    v.muted = true;
                    v.controls = false;
                } catch(e) { /* no-op */ }
            }
            if (typeof src.play === 'function') { src.play(); }
        })();
        """
    }
}
