import Testing
import Foundation
@testable import MapTilerSDK

actor MockURLSession: MTOfflineURLSessionProtocol {
    let dataResult: Result<(Data, URLResponse), Error>?
    let downloadResult: Result<(URL, URLResponse), Error>?
    private(set) var capturedRequests: [URLRequest] = []
    
    init(dataResult: Result<(Data, URLResponse), Error>? = nil,
         downloadResult: Result<(URL, URLResponse), Error>? = nil) {
        self.dataResult = dataResult
        self.downloadResult = downloadResult
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        capturedRequests.append(request)
        guard let dataResult = dataResult else {
            fatalError("dataResult not set")
        }
        switch dataResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func download(for request: URLRequest) async throws -> (URL, URLResponse) {
        capturedRequests.append(request)
        guard let downloadResult = downloadResult else {
            fatalError("downloadResult not set")
        }
        switch downloadResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

@Suite
struct MTOfflineHTTPClientTests {
    let validURL = URL(string: "https://offline-test.maptiler.local")!
    
    @Test func get_success_returnsData() async throws {
        let expectedData = "test data".data(using: .utf8)!
        let response = HTTPURLResponse(url: validURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let mockSession = MockURLSession(dataResult: .success((expectedData, response)))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        let data = try await client.get(url: validURL)
        
        #expect(data == expectedData)
        let requests = await mockSession.capturedRequests
        #expect(requests.first?.value(forHTTPHeaderField: "User-Agent") == "MapTiler-SDK-iOS")
    }
    
    @Test func download_success_movesFile() async throws {
        let response = HTTPURLResponse(url: validURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        // Create a temporary file to simulate the download
        let tempDownloadURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try "test data".write(to: tempDownloadURL, atomically: true, encoding: .utf8)
        
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        let mockSession = MockURLSession(downloadResult: .success((tempDownloadURL, response)))
        
        let customUserAgent = "Custom-Agent/1.0"
        let client = MTOfflineHTTPClient(session: mockSession, userAgent: customUserAgent)
        try await client.download(url: validURL, to: destinationURL)
        
        let downloadedData = try String(contentsOf: destinationURL, encoding: .utf8)
        #expect(downloadedData == "test data")
        
        let requests = await mockSession.capturedRequests
        #expect(requests.first?.value(forHTTPHeaderField: "User-Agent") == customUserAgent)
        
        // Clean up
        try? FileManager.default.removeItem(at: destinationURL)
    }
    
    @Test func get_http404_throwsNotFound() async throws {
        let response = HTTPURLResponse(url: validURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
        let mockSession = MockURLSession(dataResult: .success((Data(), response)))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.notFound) {
            try await client.get(url: validURL)
        }
    }
    
    @Test func get_http401_throwsClientError() async throws {
        let response = HTTPURLResponse(url: validURL, statusCode: 401, httpVersion: nil, headerFields: nil)!
        let mockSession = MockURLSession(dataResult: .success((Data(), response)))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.clientError(401)) {
            try await client.get(url: validURL)
        }
    }
    
    @Test func get_http500_throwsServerError() async throws {
        let response = HTTPURLResponse(url: validURL, statusCode: 500, httpVersion: nil, headerFields: nil)!
        let mockSession = MockURLSession(dataResult: .success((Data(), response)))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.serverError(500)) {
            try await client.get(url: validURL)
        }
    }
    
    @Test func get_invalidResponse_throwsInvalidResponse() async throws {
        let response = URLResponse(url: validURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let mockSession = MockURLSession(dataResult: .success((Data(), response)))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.invalidResponse) {
            try await client.get(url: validURL)
        }
    }
    
    @Test func get_urlErrorTimedOut_throwsTimeout() async throws {
        let urlError = URLError(.timedOut)
        let mockSession = MockURLSession(dataResult: .failure(urlError))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.timeout) {
            try await client.get(url: validURL)
        }
    }
    
    @Test func get_urlErrorNotConnected_throwsOffline() async throws {
        let urlError = URLError(.notConnectedToInternet)
        let mockSession = MockURLSession(dataResult: .failure(urlError))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.offline) {
            try await client.get(url: validURL)
        }
    }
    
    @Test func get_urlErrorOther_throwsNetworkError() async throws {
        let urlError = URLError(.badURL)
        let mockSession = MockURLSession(dataResult: .failure(urlError))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.networkError(urlError)) {
            try await client.get(url: validURL)
        }
    }
    
    @Test func get_unknownError_throwsUnknown() async throws {
        let testError = NSError(domain: "TestDomain", code: 123, userInfo: nil)
        let mockSession = MockURLSession(dataResult: .failure(testError))
        
        let client = MTOfflineHTTPClient(session: mockSession)
        
        await #expect(throws: MTOfflineHTTPError.unknown(testError.localizedDescription)) {
            try await client.get(url: validURL)
        }
    }
}
