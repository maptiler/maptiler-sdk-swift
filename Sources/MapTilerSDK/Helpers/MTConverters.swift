//
// Copyright (c) 2025, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//
//  MTConverters.swift
//  MapTilerSDK
//

import Foundation

public extension MTMapView {
    /// Converts a GPX document string to a GeoJSON FeatureCollection JSON string.
    /// - Parameter gpxString: Raw GPX XML content.
    /// - Returns: A GeoJSON FeatureCollection encoded as a JSON string.
    func convertGPXToGeoJSON(_ gpxString: String) async throws -> String {
        let result = try await bridge.execute(ConvertGPX(gpxString: gpxString))
        guard case .string(let json) = result else {
            throw MTError.unsupportedReturnType(description: "Expected GeoJSON string from GPX conversion.")
        }
        return json
    }

    /// Converts a KML document string to a GeoJSON FeatureCollection JSON string.
    /// - Parameter kmlString: Raw KML XML content.
    /// - Returns: A GeoJSON FeatureCollection encoded as a JSON string.
    func convertKMLToGeoJSON(_ kmlString: String) async throws -> String {
        let result = try await bridge.execute(ConvertKML(kmlString: kmlString))
        guard case .string(let json) = result else {
            throw MTError.unsupportedReturnType(description: "Expected GeoJSON string from KML conversion.")
        }
        return json
    }
}
