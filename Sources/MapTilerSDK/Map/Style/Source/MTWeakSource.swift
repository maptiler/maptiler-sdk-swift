//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTWeakSource.swift
//  MapTilerSDK
//

package class MTWeakSource {
    weak var source: (any MTSource)?

    init(source: MTSource? = nil) {
        self.source = source
    }
}
