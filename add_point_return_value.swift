    package func runCommandWithPointReturnValue(
        _ command: MTCommand,
        completion: ((Result<MTPoint, MTError>) -> Void)? = nil
    ) {
        Task {
            do {
                let value = try await bridge.execute(command)

                if case .stringDoubleDict(let commandValue) = value,
                   let x = commandValue["x"], let y = commandValue["y"] {
                    let point = MTPoint(x: x, y: y)
                    completion?(.success(point))
                } else {
                    MTLogger.log("\(command) returned invalid type.", type: .error)
                    completion?(
                        .failure(
                            MTError.unsupportedReturnType(description: "Expected Point, got invalid type.")
                        )
                    )
                }
            } catch {
                MTLogger.log("\(error)", type: .error)
                if let error = error as? MTError {
                    completion?(.failure(error))
                } else {
                    completion?(.failure(MTError.bridgeNotLoaded))
                }
            }
        }
    }
