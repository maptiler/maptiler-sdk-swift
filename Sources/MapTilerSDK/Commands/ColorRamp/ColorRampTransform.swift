//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  ColorRampTransform.swift
//  MapTilerSDK
//

import Foundation

package struct CloneColorRamp: MTValueCommand {
    var sourceIdentifier: String
    var targetIdentifier: String

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(sourceIdentifier);
            if (!source) { return ""; }

            window.\(targetIdentifier) = source.clone();
            return "\(targetIdentifier)";
        })();
        """
    }
}

package struct ReverseColorRamp: MTValueCommand {
    var sourceIdentifier: String
    var targetIdentifier: String
    var clone: Bool

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(sourceIdentifier);
            if (!source) { return ""; }

            const result = source.reverse({ clone: \(clone ? "true" : "false") });
            window.\(targetIdentifier) = result;
            return "\(targetIdentifier)";
        })();
        """
    }
}

package struct ScaleColorRamp: MTValueCommand {
    var sourceIdentifier: String
    var targetIdentifier: String
    var min: Double
    var max: Double
    var clone: Bool

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(sourceIdentifier);
            if (!source) { return ""; }

            const result = source.scale(\(min), \(max), { clone: \(clone ? "true" : "false") });
            window.\(targetIdentifier) = result;
            return "\(targetIdentifier)";
        })();
        """
    }
}

package struct SetStopsOnColorRamp: MTValueCommand {
    var sourceIdentifier: String
    var targetIdentifier: String
    var stopsJSON: String
    var clone: Bool

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(sourceIdentifier);
            if (!source) { return ""; }

            const stops = \(stopsJSON);
            const result = source.setStops(stops, { clone: \(clone ? "true" : "false") });
            window.\(targetIdentifier) = result;
            return "\(targetIdentifier)";
        })();
        """
    }
}

package struct ResampleColorRamp: MTValueCommand {
    var sourceIdentifier: String
    var targetIdentifier: String
    var method: String
    var samples: Int

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(sourceIdentifier);
            if (!source) { return ""; }

            const result = source.resample("\(method)", \(samples));
            window.\(targetIdentifier) = result;
            return "\(targetIdentifier)";
        })();
        """
    }
}

package struct TransparentStartColorRamp: MTValueCommand {
    var sourceIdentifier: String
    var targetIdentifier: String

    package func toJS() -> JSString {
        return """
        (() => {
            const source = window.\(sourceIdentifier);
            if (!source) { return ""; }

            const result = source.transparentStart();
            window.\(targetIdentifier) = result;
            return "\(targetIdentifier)";
        })();
        """
    }
}
