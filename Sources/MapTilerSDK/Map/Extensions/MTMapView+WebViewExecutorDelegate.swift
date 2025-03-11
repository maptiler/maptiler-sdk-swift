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
