//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ColorRampGetters.swift
//  MapTilerSDK
//

import Foundation

package struct GetColorRampBounds: MTCommand {
    var identifier: String

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(identifier);
            return JSON.stringify(source ? source.getBounds() : null);
        })();
        """
    }
}

package struct GetColorFromColorRamp: MTCommand {
    var identifier: String
    var value: Double
    var optionsJSON: String?

    package func toJS() -> JSString {
        let options = optionsJSON.map { ", \($0)" } ?? ""

        return """
        (() => {
            const source = window.\(identifier);
            return JSON.stringify(source ? source.getColor(\(value)\(options)) : null);
        })();
        """
    }
}

package struct GetColorHexFromColorRamp: MTCommand {
    var identifier: String
    var value: Double
    var optionsJSON: String?

    package func toJS() -> JSString {
        let options = optionsJSON.map { ", \($0)" } ?? ""

        return """
        (() => {
            const source = window.\(identifier);
            return source ? source.getColorHex(\(value)\(options)) : "";
        })();
        """
    }
}

package struct GetColorRelativeFromColorRamp: MTCommand {
    var identifier: String
    var value: Double
    var optionsJSON: String?

    package func toJS() -> JSString {
        let options = optionsJSON.map { ", \($0)" } ?? ""

        return """
        (() => {
            const source = window.\(identifier);
            return JSON.stringify(source ? source.getColorRelative(\(value)\(options)) : null);
        })();
        """
    }
}

package struct GetRawColorStopsFromColorRamp: MTCommand {
    var identifier: String

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(identifier);
            return JSON.stringify(source ? source.getRawColorStops() : null);
        })();
        """
    }
}

package struct GetCanvasStripFromColorRamp: MTCommand {
    var identifier: String
    var optionsJSON: String

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(identifier);
            if (!source) { return ""; }

            const canvas = source.getCanvasStrip(\(optionsJSON));
            return canvas ? canvas.toDataURL('image/png') : "";
        })();
        """
    }
}

package struct HasTransparentStartColorRamp: MTCommand {
    var identifier: String

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(identifier);
            return !!(source && source.hasTransparentStart());
        })();
        """
    }
}
