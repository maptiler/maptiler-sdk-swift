//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTGeoJSONSource+SetStringData.swift
//  MapTilerSDK
//

import Foundation

// Concurrency + legacy completion wrappers for inline string updates.
extension MTGeoJSONSource {
    /// Sets the data of the source from an inline GeoJSON string.
    ///
    /// Encodes the string and updates the underlying style source without requiring a URL.
    /// - Parameters:
    ///    - jsonString: GeoJSON string (Feature, FeatureCollection, or Geometry object).
    ///    - mapView: MTMapView which holds the source.
    ///    - completionHandler: A handler block to execute when function finishes.
    @MainActor
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func setData(jsonString: String, in mapView: MTMapView, completionHandler: ((Result<Void, MTError>) -> Void)? = nil) {
        mapView.setData(jsonString: jsonString, to: self, completionHandler: completionHandler)
    }

    /// Sets the data of the source from an inline GeoJSON string (async).
    /// - Parameters:
    ///    - jsonString: GeoJSON string (Feature, FeatureCollection, or Geometry object).
    ///    - mapView: MTMapView which holds the source.
    @MainActor
    public func setData(jsonString: String, in mapView: MTMapView) async {
        await mapView.setData(jsonString: jsonString, to: self)
    }
}

