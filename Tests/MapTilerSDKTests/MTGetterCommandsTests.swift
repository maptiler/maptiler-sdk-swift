import XCTest
@testable import MapTilerSDK

final class MTGetterCommandsTests: XCTestCase {

    func testGetCameraHashCommandToJS() {
        let command = GetCameraHash()
        XCTAssertEqual(command.toJS(), "map.getCameraHash() ?? 'null';")
    }

    func testGetFilterCommandToJS() {
        let command = GetFilter(layerId: "water")
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getFilter('water')) ?? 'null';")
    }

    func testGetGlyphsCommandToJS() {
        let command = GetGlyphs()
        XCTAssertEqual(command.toJS(), "map.getGlyphs() ?? 'null';")
    }

    func testGetLayersOrderCommandToJS() {
        let command = GetLayersOrder()
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getLayersOrder()) ?? 'null';")
    }

    func testGetLayoutPropertyCommandToJS() {
        let command = GetLayoutProperty(layerId: "water", name: "visibility")
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getLayoutProperty('water', 'visibility')) ?? 'null';")
    }

    func testGetLightCommandToJS() {
        let command = GetLight()
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getLight()) ?? 'null';")
    }

    func testGetPaintPropertyCommandToJS() {
        let command = GetPaintProperty(layerId: "water", name: "fill-color")
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getPaintProperty('water', 'fill-color')) ?? 'null';")
    }
}
