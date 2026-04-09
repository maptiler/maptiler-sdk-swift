//
// Copyright (c) 2026, MapTiler
// All rights reserved.
// SPDX-License-Identifier: BSD 3-Clause
//

import Testing
import CoreLocation
@testable import MapTilerSDK

@Suite("MTBoundingBox Normalization and Splitting Tests")
struct MTBoundingBoxTests {
    
    @Test("Normalize out-of-bounds longitudes")
    func normalizeLongitude() {
        // Normal cases
        #expect(MTBoundingBox.normalizeLongitude(10.0) == 10.0)
        #expect(MTBoundingBox.normalizeLongitude(-10.0) == -10.0)
        
        // Edge cases
        #expect(MTBoundingBox.normalizeLongitude(180.0) == 180.0)
        #expect(MTBoundingBox.normalizeLongitude(-180.0) == -180.0)
        
        // Out of bounds
        #expect(MTBoundingBox.normalizeLongitude(190.0) == -170.0)
        #expect(MTBoundingBox.normalizeLongitude(360.0) == 0.0)
        #expect(MTBoundingBox.normalizeLongitude(370.0) == 10.0)
        
        #expect(MTBoundingBox.normalizeLongitude(-200.0) == 160.0)
        #expect(MTBoundingBox.normalizeLongitude(-360.0) == 0.0)
        #expect(MTBoundingBox.normalizeLongitude(-370.0) == -10.0)
    }
    
    @Test("Clamp extreme latitudes")
    func clampLatitude() {
        let maxWebMercatorLat = 85.05112877980659
        
        // Normal cases
        #expect(MTBoundingBox.clampLatitude(45.0) == 45.0)
        #expect(MTBoundingBox.clampLatitude(-45.0) == -45.0)
        
        // Extreme cases
        #expect(MTBoundingBox.clampLatitude(90.0) == maxWebMercatorLat)
        #expect(MTBoundingBox.clampLatitude(100.0) == maxWebMercatorLat)
        #expect(MTBoundingBox.clampLatitude(-90.0) == -maxWebMercatorLat)
        #expect(MTBoundingBox.clampLatitude(-100.0) == -maxWebMercatorLat)
    }
    
    @Test("Correct behavior for a BBox that does not cross the Dateline")
    func standardBBox() {
        let bbox = MTBoundingBox(minLon: 10, minLat: 20, maxLon: 30, maxLat: 40)
        let split = bbox.normalizedAndSplit()
        
        #expect(split.count == 1)
        #expect(split[0] == MTBoundingBox(minLon: 10, minLat: 20, maxLon: 30, maxLat: 40))
        #expect(split[0].crossesAntimeridian == false)
    }
    
    @Test("Correct splitting of a BBox crossing the antimeridian")
    func datelineCrossingBBox() {
        // e.g. spanning from 170 to 190 (which normalizes to -170)
        let bbox = MTBoundingBox(minLon: 170, minLat: -10, maxLon: 190, maxLat: 10)
        let split = bbox.normalizedAndSplit()
        
        #expect(split.count == 2)
        
        let leftBox = split[0]
        #expect(leftBox.minLon == 170)
        #expect(leftBox.maxLon == 180)
        #expect(leftBox.minLat == -10)
        #expect(leftBox.maxLat == 10)
        
        let rightBox = split[1]
        #expect(rightBox.minLon == -180)
        #expect(rightBox.maxLon == -170)
        #expect(rightBox.minLat == -10)
        #expect(rightBox.maxLat == 10)
    }
    
    @Test("BBox covering the entire globe")
    func entireGlobeBBox() {
        let bbox = MTBoundingBox(minLon: -200, minLat: -90, maxLon: 200, maxLat: 90)
        let split = bbox.normalizedAndSplit()
        
        #expect(split.count == 1)
        
        let maxWebMercatorLat = MTBoundingBox.maxWebMercatorLat
        
        #expect(split[0] == MTBoundingBox(minLon: -180, minLat: -maxWebMercatorLat, maxLon: 180, maxLat: maxWebMercatorLat))
    }
    
    @Test("MTBounds Interoperability")
    func boundsInteroperability() {
        let bounds = MTBounds(southWest: CLLocationCoordinate2D(latitude: 10, longitude: 20), northEast: CLLocationCoordinate2D(latitude: 30, longitude: 40))
        let bbox = MTBoundingBox(bounds: bounds)
        #expect(bbox.minLat == 10)
        #expect(bbox.minLon == 20)
        #expect(bbox.maxLat == 30)
        #expect(bbox.maxLon == 40)
        
        let convertedBounds = bbox.bounds
        #expect(convertedBounds.southWest.latitude == 10)
        #expect(convertedBounds.southWest.longitude == 20)
        #expect(convertedBounds.northEast.latitude == 30)
        #expect(convertedBounds.northEast.longitude == 40)
    }
    
    @Test("Initialization from Coordinates")
    func initFromCoordinates() {
        let coords = [
            CLLocationCoordinate2D(latitude: 10, longitude: -10),
            CLLocationCoordinate2D(latitude: 20, longitude: 10),
            CLLocationCoordinate2D(latitude: 15, longitude: 0)
        ]
        let bbox = MTBoundingBox(coordinates: coords)
        #expect(bbox != nil)
        #expect(bbox?.minLat == 10)
        #expect(bbox?.maxLat == 20)
        #expect(bbox?.minLon == -10)
        #expect(bbox?.maxLon == 10)
        
        let emptyBbox = MTBoundingBox(coordinates: [])
        #expect(emptyBbox == nil)
    }
    
    @Test("Expanded Bounding Box")
    func expandedBoundingBox() {
        let bbox = MTBoundingBox(minLon: 10, minLat: 10, maxLon: 20, maxLat: 20)
        let expanded = bbox.expanded(by: 0.1)
        
        #expect(expanded.minLon == 9)
        #expect(expanded.maxLon == 21)
        #expect(expanded.minLat == 9)
        #expect(expanded.maxLat == 21)
    }
    
    @Test("Area Calculation")
    func areaCalculation() {
        // Approximate area of a 1x1 degree square at the equator should be ~12391 km^2
        let bbox = MTBoundingBox(minLon: 0, minLat: 0, maxLon: 1, maxLat: 1)
        let area = bbox.areaInSquareKilometers
        // It's around 12364
        #expect(area > 12000 && area < 13000)
    }
    
    @Test("Tile Count Estimator")
    func tileCountEstimator() throws {
        let bbox = MTBoundingBox(minLon: -0.1, minLat: -0.1, maxLon: 0.1, maxLat: 0.1)
        let zoomRange = try MTOfflineZoomRange(minZoom: 0, maxZoom: 1)
        let estimate = bbox.estimatedTileCount(zoomRange: zoomRange)
        
        // zoom 0: 1 tile
        // zoom 1: covers the center, could be 1-4 tiles depending on rounding, but for (-0.1..0.1) it's likely 4 tiles
        #expect(estimate > 0)
    }
}
