sed -i '' -e '/@MainActor/ {
  /@Test func setSpriteWrapper_shouldDispatchCommand() async throws {/i\
    @MainActor\
    @Test func removeSpriteWrapper_shouldDispatchCommand() async throws {\
        let executor = MockExecutor()\
        let mapView = MTMapView(frame: .zero)\
\
        mapView.bridge.executor = executor\
\
        let result = await withCheckedContinuation { continuation in\
            mapView.removeSprite(id: "sprite-wrapper") { outcome in\
                continuation.resume(returning: outcome)\
            }\
        }\
\
        switch result {\
        case .success:\
            break\
        case .failure(let error):\
            Issue.record("Expected removeSprite wrapper to succeed, but failed with \\(error)")\
        }\
\
        let command = executor.lastCommand as? RemoveSprite\
\
        #expect(command?.id == "sprite-wrapper")\
    }\
\
    @MainActor\
    @Test func removeSpriteAsyncWrapper_shouldDispatchCommand() async throws {\
        let executor = MockExecutor()\
        let mapView = MTMapView(frame: .zero)\
\
        mapView.bridge.executor = executor\
\
        await mapView.removeSprite(id: "async-sprite")\
\
        let command = executor.lastCommand as? RemoveSprite\
\
        #expect(command?.id == "async-sprite")\
    }\
\

}' Tests/MapTilerSDKTests/MTStyleTests.swift
