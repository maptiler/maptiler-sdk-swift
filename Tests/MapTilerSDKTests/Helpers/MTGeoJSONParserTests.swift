import XCTest
import CoreLocation
@testable import MapTilerSDK

final class MTGeoJSONParserTests: XCTestCase {

    func testExtractLineString() throws {
        let geoJSONString = """
        {
          "type": "LineString",
          "coordinates": [
            [14.42, 50.08],
            [14.43, 50.09]
          ]
        }
        """
        let coordinates = try MTGeoJSONParser.extractCoordinates(from: geoJSONString)
        XCTAssertEqual(coordinates.count, 2)
        XCTAssertEqual(coordinates[0].longitude, 14.42)
        XCTAssertEqual(coordinates[0].latitude, 50.08)
        XCTAssertEqual(coordinates[1].longitude, 14.43)
        XCTAssertEqual(coordinates[1].latitude, 50.09)
    }

    func testExtractFeatureCollection() throws {
        let geoJSONString = """
        {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [10.0, 20.0]
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "LineString",
                "coordinates": [[11.0, 21.0], [12.0, 22.0]]
              }
            }
          ]
        }
        """
        let coordinates = try MTGeoJSONParser.extractCoordinates(from: geoJSONString)
        XCTAssertEqual(coordinates.count, 3)
        XCTAssertEqual(coordinates[0].longitude, 10.0)
        XCTAssertEqual(coordinates[1].longitude, 11.0)
        XCTAssertEqual(coordinates[2].longitude, 12.0)
    }
}
