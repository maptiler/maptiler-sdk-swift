import Testing
@testable import MapTilerSDK

import CoreLocation

@Suite
struct CoordinatesTests {
    @Test func clLocationCoordinate2D_tolngLat_shouldConvertCorrectly() async throws {
        let conversionFailureMessage = "Conversion between CLLocationCoordinate2D and LngLat failed"
        
        let latitude: Double = 10.0
        let longitude: Double = 20.0
        
        let nativeCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let lngLat = nativeCoordinates.toLngLat()
        
        assert(nativeCoordinates.latitude == lngLat.lat, conversionFailureMessage)
        assert(nativeCoordinates.longitude == lngLat.lng, conversionFailureMessage)
    }
}
