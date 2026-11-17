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

    func testGetSkyCommandToJS() {
        let command = GetSky()
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getSky()) ?? 'null';")
    }

    func testGetSourceCommandToJS() {
        let command = GetSource(id: "my-source")
        let expected = "JSON.stringify(map.getSource('my-source') ? "
            + "map.getSource('my-source').serialize() : null) ?? 'null';"
        XCTAssertEqual(command.toJS(), expected)
    }

    func testGetSpriteCommandToJS() {
        let command = GetSprite()
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getSprite()) ?? 'null';")
    }

    func testGetStyleCommandToJS() {
        let command = GetStyle()
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getStyle()) ?? 'null';")
    }

    func testGetTerrainCommandToJS() {
        let command = GetTerrain()
        XCTAssertEqual(command.toJS(), "JSON.stringify(map.getTerrain()) ?? 'null';")
    }

    func testGetTerrainExaggerationCommandToJS() {
        let command = GetTerrainExaggeration()
        XCTAssertEqual(command.toJS(), "map.getTerrainExaggeration();")
    }

    func testGetVerticalFieldOfViewCommandToJS() {
        let command = GetVerticalFieldOfView()
        XCTAssertEqual(command.toJS(), "map.getVerticalFieldOfView();")
    }

    func testIsLanguageUpdatedCommandToJS() {
        let command = IsLanguageUpdated()
        XCTAssertEqual(command.toJS(), "map.isLanguageUpdated();")
    }
}
