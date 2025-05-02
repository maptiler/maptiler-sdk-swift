//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTMapView+WebViewExecutorDelegate.swift
//  MapTilerSDK
//

import WebKit

extension MTMapView: WebViewExecutorDelegate {
    package func webViewExecutor(_ executor: WebViewExecutor, didFinishNavigation navigation: WKNavigation) {
        initializeMap()
    }
}
