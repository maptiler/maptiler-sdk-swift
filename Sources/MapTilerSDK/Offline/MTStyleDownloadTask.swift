import Foundation

internal struct MTStyleDownloadTask: MTDownloadTask {
    internal let id: String
    internal let resource: MTMapResource
    internal let packId: String
    internal var destinationURL: URL? {
        MTOfflineStoragePaths.absoluteURL(for: packId, relativePath: resource.destinationPath)
    }

    private let session: URLSession

    internal init(resource: MTMapResource, packId: String, session: URLSession = MTConfig.sharedURLSession) {
        self.id = resource.url.absoluteString
        self.resource = resource
        self.packId = packId
        self.session = session
    }

    internal func execute() async throws {
        let retryPolicy = MTNetworkRetryPolicy(maxAttempts: 8)

        do {
            try await retryPolicy.execute {
                let normalizedURL = await MTURLNormalizer.normalize(url: resource.url)
                let (data, response) = try await session.data(from: normalizedURL)

                try response.validateHTTPStatus()

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw MTOfflineError.networkError(URLError(.badServerResponse))
                }

                if httpResponse.statusCode == 204 {
                    // Server explicitly returned no content. Treat as success.
                    return
                }

                guard let dest = destinationURL else { return }
                try await MTOfflineStorage.write(data, to: dest)
            }
        } catch let error as MTOfflineHTTPError {
            switch error {
            case .tooManyRequests(let retryAfter):
                throw MTOfflineError.rateLimitExceeded(retryAfter: retryAfter)
            case .notFound:
                throw MTOfflineError.badResponse(statusCode: 404)
            case .serverError(let code), .clientError(let code):
                throw MTOfflineError.badResponse(statusCode: code)
            case .timeout:
                throw MTOfflineError.networkError(URLError(.timedOut))
            default:
                throw MTOfflineError.networkError(URLError(.badServerResponse))
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
