import Testing
import Foundation
@testable import MapTilerSDK

@Suite
struct MTSpriteSpecialTests {
    @Test func addSpriteCommand_shouldHandleSpecialCharactersInId() async throws {
        let spriteURL = URL(string: "https://example.com/sprite.png")!
        let command = AddSprite(id: "---!@#", url: spriteURL)
        let expectedJS = "\(MTBridge.mapObject).addSprite(\"---!@#\", \"\(spriteURL.absoluteString)\");"
        #expect(command.toJS() == expectedJS)
    }

    @Test func addSpriteCommand_shouldHandleQuotesInId() async throws {
        let spriteURL = URL(string: "https://example.com/sprite.png")!
        let command = AddSprite(id: "my\"id", url: spriteURL)
        let expectedJS = "\(MTBridge.mapObject).addSprite(\"my\\\"id\", \"\(spriteURL.absoluteString)\");"
        #expect(command.toJS() == expectedJS)
    }
}
