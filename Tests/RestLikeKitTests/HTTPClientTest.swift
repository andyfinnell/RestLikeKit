import Foundation
import Combine
import XCTest
@testable import RestLikeKit

final class HTTPClientTest: XCTestCase {
    var subject: HTTPClient!
    var request: HTTPRequest<RestLikeKit.Empty>!
    var cancellables: Set<AnyCancellable>!
    var httpRequestEncoder: FakeHTTPRequestEncoder!
    var urlSession: FakeURLSession!
    
    override func setUp() {
        super.setUp()
        httpRequestEncoder = FakeHTTPRequestEncoder()
        urlSession = FakeURLSession()
        subject = HTTPClient(logger: FakeLogger(),
                             urlSession: urlSession,
                             httpRequestEncoder: httpRequestEncoder,
                             httpResponseDecoder: HTTPResponseDecoder())
        request = HTTPRequest<RestLikeKit.Empty>(method: .get,
                                     url: URL(string: "https://example.com")!,
                                     headers: [HTTPHeader.accept: "application/json"],
                                     body: .json(Empty()),
                                     shouldRedactRequestBody: false,
                                     shouldRedactResponseBody: false)
        cancellables = Set()
    }
    
    func testSend_encodeThrows_returnsFailure() {
        var wasSuccess: Bool?
        let completeExpectation = expectation(description: "complete")
        
        httpRequestEncoder.encode_stubbed = nil
        subject.send(request: request, responseFormat: HTTPResponse<RestLikeKit.Empty>.Format.empty)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    wasSuccess = true
                case .failure:
                    wasSuccess = false
                }
                completeExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)
                
        wait(until: httpRequestEncoder.encode_wasCalled)

        XCTAssertTrue(httpRequestEncoder.encode_wasCalled)
        
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertFalse(wasSuccess!)
    }
    
    func testSend_encodeSucceeds_dataTaskFails_returnsFailure() {
        var wasSuccess: Bool?
        let completeExpectation = expectation(description: "complete")

        httpRequestEncoder.encode_stubbed = URLRequest(url: URL(string: "https://example.com")!)
        subject.send(request: request, responseFormat: HTTPResponse<RestLikeKit.Empty>.Format.empty)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    wasSuccess = true
                case .failure:
                    wasSuccess = false
                }
                completeExpectation.fulfill()
            }, receiveValue: { _ in
            }).store(in: &cancellables)
        
        wait(until: urlSession.dataTask_wasCalled)
        wait(until: urlSession.dataTask_stubbed.resume_wasCalled)

        XCTAssertTrue(httpRequestEncoder.encode_wasCalled)
        XCTAssertTrue(urlSession.dataTask_wasCalled)
        XCTAssertEqual(urlSession.dataTask_wasCalled_withArgs?.request, httpRequestEncoder.encode_stubbed)
        XCTAssertTrue(urlSession.dataTask_stubbed.resume_wasCalled)

        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.completion)
        let completion = urlSession.dataTask_wasCalled_withArgs?.completion
        completion?(nil, nil, HTTPError.statusCode(404))
    
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertFalse(wasSuccess!)
    }
    
    func testSend_encodeSucceeds_dataTaskSucceeds_returnsSucceess() {
        var finalResult: HTTPResponse<RestLikeKit.Empty>?
        var wasSuccess: Bool?
        let completeExpectation = expectation(description: "complete")

        httpRequestEncoder.encode_stubbed = URLRequest(url: URL(string: "https://example.com")!)
        subject.send(request: request, responseFormat: HTTPResponse<RestLikeKit.Empty>.Format.empty)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    wasSuccess = true
                case .failure:
                    wasSuccess = false
                }
                completeExpectation.fulfill()
            }, receiveValue: { result in
                finalResult = result
            }).store(in: &cancellables)

        wait(until: httpRequestEncoder.encode_wasCalled)

        XCTAssertTrue(httpRequestEncoder.encode_wasCalled)
        XCTAssertTrue(urlSession.dataTask_wasCalled)
        XCTAssertEqual(urlSession.dataTask_wasCalled_withArgs?.request, httpRequestEncoder.encode_stubbed)
        XCTAssertTrue(urlSession.dataTask_stubbed.resume_wasCalled)

        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.completion)
        let completion = urlSession.dataTask_wasCalled_withArgs?.completion
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        completion?(nil, urlResponse, nil)
    
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertTrue(wasSuccess!)
        let expectedResponse = HTTPResponse<RestLikeKit.Empty>(status: 200, url: URL(string: "https://example.com")!, body: Empty(), headers: ["Content-Type": "application/json"])
        XCTAssertEqual(finalResult, expectedResponse)
    }
}
