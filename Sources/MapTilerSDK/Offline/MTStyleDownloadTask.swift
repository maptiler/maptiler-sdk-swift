import Foundation

internal struct MTStyleDownloadTask: MTDownloadTask {
    internal let id: String
    internal let resource: MTMapResource
    internal let packId: String
    internal var destinationURL: URL? { URL(fileURLWithPath: resource.destinationPath) }

    private let session: URLSession

    internal init(resource: MTMapResource, packId: String, session: URLSession = MTConfig.sharedURLSession) {
        self.id = resource.url.absoluteString
        self.resource = resource
        self.packId = packId
        self.session = session
    }

    internal func execute() async throws {
        let retryPolicy = MTNetworkRetryPolicy(maxAttempts: 3)

        do {
            try await retryPolicy.execute {
                let (data, response) = try await session.data(from: resource.url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw MTOfflineError.networkError(URLError(.badServerResponse))
                }

                switch httpResponse.statusCode {
                case 204:
                    throw MTOfflineError.noContent
                case 200...299:
                    break
                default:
                    throw MTOfflineError.badResponse(statusCode: httpResponse.statusCode)
                }

                guard let dest = destinationURL else { return }

                // Process the style JSON
                if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let baseURL = MTOfflineHTTPServer.shared.baseURLString()
                    let processor = MTStyleProcessor(baseURL: baseURL, packName: packId)
                    let transformed = processor.transform(style: jsonObject)
                    let transformedData = try JSONSerialization.data(withJSONObject: transformed, options: [])
                    try await MTOfflineStorage.write(transformedData, to: dest)
                } else {
                    // Fallback to original data if parsing fails
                    try await MTOfflineStorage.write(data, to: dest)
                }
            }
        } catch let error as MTOfflineError {
            throw error
        } catch let error as MTOfflinePackError {
            throw error
        } catch let error as URLError {
            throw MTOfflineError.networkError(error)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw MTOfflineError.fileSystemError(error.localizedDescription)
        }
    }
}
