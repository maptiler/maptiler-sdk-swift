import re

with open('Sources/MapTilerSDK/Map/Extensions/MTNavigable/MTMapView+MTNavigable.swift', 'r') as f:
    content = f.read()

# sync version
sync_pattern = r'''    public func snapToNorth\(
        animationOptions: MTAnimationOptions\? = nil,
        completionHandler: \(\(Result<Void, MTError>\) -> Void\)\? = nil
    \) \{
        runCommand\(SnapToNorth\(animationOptions: animationOptions\), completion: completionHandler\)
    \}'''
sync_replacement = r'''    public func snapToNorth(
        animationOptions: MTAnimationOptions? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(SnapToNorth(animationOptions: animationOptions), completion: completionHandler)
    }

    /// Resets the map bearing to 0 degrees.
    /// - Parameters:
    ///   - animationOptions: Animation options.
    ///   - completionHandler: A handler block to execute when function finishes.
    @available(iOS, deprecated: 16.0, message: "Prefer the async version for modern concurrency handling")
    public func resetNorth(
        animationOptions: MTAnimationOptions? = nil,
        completionHandler: ((Result<Void, MTError>) -> Void)? = nil
    ) {
        runCommand(ResetNorth(animationOptions: animationOptions), completion: completionHandler)
    }'''

content = re.sub(sync_pattern, sync_replacement, content)

# async version
async_pattern = r'''    public func snapToNorth\(animationOptions: MTAnimationOptions\? = nil\) async \{
        await withCheckedContinuation \{ continuation in
            snapToNorth\(animationOptions: animationOptions\) \{ _ in
                continuation.resume\(\)
            \}
        \}
    \}'''
async_replacement = r'''    public func snapToNorth(animationOptions: MTAnimationOptions? = nil) async {
        await withCheckedContinuation { continuation in
            snapToNorth(animationOptions: animationOptions) { _ in
                continuation.resume()
            }
        }
    }

    /// Resets the map bearing to 0 degrees.
    /// - Parameters:
    ///   - animationOptions: Animation options.
    public func resetNorth(animationOptions: MTAnimationOptions? = nil) async {
        await withCheckedContinuation { continuation in
            resetNorth(animationOptions: animationOptions) { _ in
                continuation.resume()
            }
        }
    }'''

content = re.sub(async_pattern, async_replacement, content)

with open('Sources/MapTilerSDK/Map/Extensions/MTNavigable/MTMapView+MTNavigable.swift', 'w') as f:
    f.write(content)
