//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  GetMaxBounds.swift
//  MapTilerSDK
//

package struct GetMaxBounds: MTValueCommand {
    package func toJS() -> JSString {
        return """
(() => {
    const bounds = \(MTBridge.mapObject).getMaxBounds();
    return bounds ? JSON.stringify(bounds.toArray()) : null;
})()
"""
    }
}
