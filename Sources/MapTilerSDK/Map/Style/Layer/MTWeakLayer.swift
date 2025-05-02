//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTWeakLayer.swift
//  MapTilerSDK
//

package class MTWeakLayer {
    weak var layer: (any MTLayer)?

    init(layer: MTLayer? = nil) {
        self.layer = layer
    }
}
