import XCTest
@testable import MapTilerSDK

final class MTOfflineConfigurationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset to defaults before each test
        MTOfflineConfiguration.shared.userMaxTileCount = 15000
    }

    override func tearDown() {
        // Reset to defaults after each test
        MTOfflineConfiguration.shared.userMaxTileCount = 15000
        super.tearDown()
    }

    func testDefaultLimits() {
        XCTAssertEqual(MTOfflineConfiguration.shared.internalMaxTileLimit, 15000)
        XCTAssertEqual(MTOfflineConfiguration.shared.userMaxTileCount, 15000)
        XCTAssertEqual(MTOfflineConfiguration.shared.effectiveGlobalLimit, 15000)
    }

    func testUserLimitLowerThanInternalLimit() {
        MTOfflineConfiguration.shared.userMaxTileCount = 5000
        XCTAssertEqual(MTOfflineConfiguration.shared.effectiveGlobalLimit, 5000)
    }

    func testUserLimitHigherThanInternalLimit() {
        MTOfflineConfiguration.shared.userMaxTileCount = 50000
        XCTAssertEqual(MTOfflineConfiguration.shared.effectiveGlobalLimit, 15000)
    }

    func testMTConfigUpdatesUserLimit() async {
        await MTConfig.shared.setOfflineMaxTileCount(8000)
        XCTAssertEqual(MTOfflineConfiguration.shared.userMaxTileCount, 8000)
        XCTAssertEqual(MTOfflineConfiguration.shared.effectiveGlobalLimit, 8000)

        // Reset
        await MTConfig.shared.setOfflineMaxTileCount(15000)
    }
}
