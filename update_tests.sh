sed -i '' -e '/@Test func setSpriteCommand_shouldGenerateExpectedJS/i\
    @Test func removeSpriteCommand_shouldGenerateExpectedJS() async throws {\
        let command = RemoveSprite(id: "test-sprite")\
        let expectedJS = "\\(MTBridge.mapObject).removeSprite(\\"test-sprite\\");"\
\
        #expect(command.toJS() == expectedJS)\
    }\
' Tests/MapTilerSDKTests/MTStyleTests.swift
