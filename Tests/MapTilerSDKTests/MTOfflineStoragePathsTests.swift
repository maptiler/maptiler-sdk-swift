import XCTest
@testable import MapTilerSDK

final class MTOfflineStoragePathsTests: XCTestCase {
    
    func testRootDirectory() {
        let url = MTOfflineStoragePaths.rootDirectory
        XCTAssertTrue(url.path.hasSuffix("/Documents/MTOffline"), "Root directory should end with /Documents/MTOffline")
        XCTAssertTrue(url.hasDirectoryPath, "Root directory should be a directory")
    }
    
    func testPackDirectory() {
        let url = MTOfflineStoragePaths.packDirectory(for: "test-pack-123")
        XCTAssertTrue(url.path.hasSuffix("/Documents/MTOffline/test-pack-123"), "Pack directory should end with /Documents/MTOffline/test-pack-123")
        XCTAssertTrue(url.hasDirectoryPath, "Pack directory should be a directory")
    }
    
    func testStyleURL() {
        let url = MTOfflineStoragePaths.styleURL(for: "test-pack-123")
        XCTAssertTrue(url.path.hasSuffix("/Documents/MTOffline/test-pack-123/style.json"), "Style URL should end with style.json")
        XCTAssertFalse(url.hasDirectoryPath, "Style URL should be a file")
    }
    
    func testSpriteURL() {
        let urlBase = MTOfflineStoragePaths.spriteURL(for: "test-pack-123", scale: 1, isJSON: false)
        XCTAssertTrue(urlBase.path.hasSuffix("/Documents/MTOffline/test-pack-123/sprite.png"), "Sprite base PNG should end with sprite.png")
        XCTAssertFalse(urlBase.hasDirectoryPath, "Sprite base PNG should be a file")
        
        let urlBaseJSON = MTOfflineStoragePaths.spriteURL(for: "test-pack-123", scale: 1, isJSON: true)
        XCTAssertTrue(urlBaseJSON.path.hasSuffix("/Documents/MTOffline/test-pack-123/sprite.json"), "Sprite base JSON should end with sprite.json")
        XCTAssertFalse(urlBaseJSON.hasDirectoryPath, "Sprite base JSON should be a file")
        
        let url2x = MTOfflineStoragePaths.spriteURL(for: "test-pack-123", scale: 2, isJSON: false)
        XCTAssertTrue(url2x.path.hasSuffix("/Documents/MTOffline/test-pack-123/sprite@2x.png"), "Sprite @2x PNG should end with sprite@2x.png")
        
        let url2xJSON = MTOfflineStoragePaths.spriteURL(for: "test-pack-123", scale: 2, isJSON: true)
        XCTAssertTrue(url2xJSON.path.hasSuffix("/Documents/MTOffline/test-pack-123/sprite@2x.json"), "Sprite @2x JSON should end with sprite@2x.json")
    }
    
    func testGlyphsURL() {
        let url = MTOfflineStoragePaths.glyphsURL(for: "test-pack-123", fontStack: "Noto Sans Regular", range: "0-255")
        XCTAssertTrue(url.path.hasSuffix("/Documents/MTOffline/test-pack-123/glyphs/Noto Sans Regular/0-255.pbf"), "Glyphs URL should be constructed correctly")
        XCTAssertFalse(url.hasDirectoryPath, "Glyphs URL should be a file")
    }
    
    func testTileURL() {
        let url = MTOfflineStoragePaths.tileURL(for: "test-pack-123", sourceId: "maptiler-planet", z: 10, x: 500, y: 600)
        XCTAssertTrue(url.path.hasSuffix("/Documents/MTOffline/test-pack-123/tiles/maptiler-planet/10/500/600.pbf"), "Tile URL should be constructed correctly")
        XCTAssertFalse(url.hasDirectoryPath, "Tile URL should be a file")
    }
}
