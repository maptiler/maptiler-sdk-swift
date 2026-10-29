import Foundation

// Serves canned responses by URL (ignoring query parameters) and records every request,
// so tests can assert exactly which requests estimation and planning make.
final class EstimationMockURLProtocol: URLProtocol {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var responses: [String: Data] = [:]
    nonisolated(unsafe) private static var requests: [String] = []

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [EstimationMockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    static func register(_ url: String, json: String) {
        lock.withLock { responses[url] = Data(json.utf8) }
    }

    // Requests made to the given host, without query parameters.
    static func requests(toHost host: String) -> [String] {
        lock.withLock { requests.filter { URL(string: $0)?.host == host } }
    }

    private static func strippingQuery(_ url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.query = nil
        return components?.url?.absoluteString ?? url.absoluteString
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else { return }
        let key = EstimationMockURLProtocol.strippingQuery(url)
        let data = EstimationMockURLProtocol.lock.withLock {
            EstimationMockURLProtocol.requests.append(key)
            return EstimationMockURLProtocol.responses[key]
        }

        let statusCode = data == nil ? 404 : 200
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data ?? Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
