import Testing
@testable import MapTilerSDK

import UIKit
import CoreLocation

@Suite
struct HelperTests {
    @Test func clLocationCoordinate2D_tolngLat_shouldConvertCorrectly() async throws {
        let conversionFailureMessage = "Conversion between CLLocationCoordinate2D and LngLat failed"

        let latitude: Double = 10.0
        let longitude: Double = 20.0

        let nativeCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let lngLat = nativeCoordinates.toLngLat()

        assert(nativeCoordinates.latitude == lngLat.lat, conversionFailureMessage)
        assert(nativeCoordinates.longitude == lngLat.lng, conversionFailureMessage)
    }

    @Test func clLocationCoordinate2D_toJSON_notNil() async throws {
        let coordinates = CLLocationCoordinate2D(latitude: 19.2150224, longitude: 44.7569511)

        #expect(coordinates.toJSON() != nil)
    }

    @Test func color_toHex_shouldConvertCorrectly() async throws {
        let color: UIColor = .white
        let resultHex = "#FFFFFF"

        #expect(color.toHex() == resultHex)
    }

    @Test func mtLanguage_shouldDecodeCorrectly() async throws {
        for language in MTCountryLanguage.allCases {
            let decoder = JSONDecoder()
            let decodedLanguage = try decoder.decode(MTCountryLanguage.self, from: Data(language.toJSON()!.utf8))

            #expect(decodedLanguage.rawValue == language.rawValue)
        }

    }
}
