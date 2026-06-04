import Foundation
import CoreLocation
import MapTilerSDK

enum AreaCalculator {
    /// Calculates the approximate area of an MTBoundingBox in square kilometers using the Haversine formula
    /// to calculate the width and height, then multiplying them.
    static func areaInSquareKilometers(for bbox: MTBoundingBox) -> Double {
        let earthRadiusInKM = 6371.0

        // Helper to convert degrees to radians
        let toRadians = { (degrees: Double) -> Double in
            return degrees * .pi / 180.0
        }

        let minLat = toRadians(bbox.minLat)
        let maxLat = toRadians(bbox.maxLat)
        let minLon = toRadians(bbox.minLon)
        let maxLon = toRadians(bbox.maxLon)

        // Calculate height (difference in latitude)
        let heightDistance = earthRadiusInKM * (maxLat - minLat)

        // Calculate width (difference in longitude at average latitude)
        let avgLat = (minLat + maxLat) / 2.0
        let widthDistance = earthRadiusInKM * cos(avgLat) * (maxLon - minLon)

        return abs(widthDistance * heightDistance)
    }
}
