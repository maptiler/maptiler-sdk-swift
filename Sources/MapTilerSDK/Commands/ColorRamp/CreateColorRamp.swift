//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  CreateColorRamp.swift
//  MapTilerSDK
//

import Foundation

package struct CreateColorRamp: MTCommand {
    var identifier: String
    var optionsJSON: String

    package func toJS() -> JSString {
        return """
        (() => {
            if (!window.\(identifier)) {
                window.\(identifier) = new \(MTBridge.sdkObject).ColorRamp(\(optionsJSON));
            }

            return null;
        })();
        """
    }
}

package struct CreateColorRampFromPreset: MTCommand {
    var identifier: String
    var preset: String

    package func toJS() -> JSString {
        return """
        (() => {
            if (!window.\(identifier)) {
                const base = \(MTBridge.sdkObject).ColorRampCollection.\(preset);
                window.\(identifier) = base ? base.clone() : null;
            }

            return null;
        })();
        """
    }
}

package struct CreateColorRampFromArrayDefinition: MTCommand {
    var identifier: String
    var definitionJSON: String

    package func toJS() -> JSString {
        return """
        (() => {
            if (!window.\(identifier)) {
                window.\(identifier) = \(MTBridge.sdkObject).ColorRamp.fromArrayDefinition(\(definitionJSON));
            }

            return null;
        })();
        """
    }
}
