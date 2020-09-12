import Foundation
import Combine
import XCTest
@testable import RestLikeKit

final class HTTPClientTest: XCTestCase {
    var subject: HTTPClient!
    var dependencies: FakeDependencies!
    var request: HTTPRequest<RestLikeKit.Empty>!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        dependencies = FakeDependencies()
        subject = HTTPClient(dependencies: dependencies)
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
        
        dependencies.fakeHTTPRequestEncoder.encode_stubbed = nil
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
                
        wait(until: dependencies.fakeHTTPRequestEncoder.encode_wasCalled)

        XCTAssertTrue(dependencies.fakeHTTPRequestEncoder.encode_wasCalled)
        
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertFalse(wasSuccess!)
    }
    
    func testSend_encodeSucceeds_dataTaskFails_returnsFailure() {
        var wasSuccess: Bool?
        let completeExpectation = expectation(description: "complete")

        dependencies.fakeHTTPRequestEncoder.encode_stubbed = URLRequest(url: URL(string: "https://example.com")!)
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
        
        wait(until: dependencies.fakeHTTPRequestEncoder.encode_wasCalled)
        
        XCTAssertTrue(dependencies.fakeHTTPRequestEncoder.encode_wasCalled)
        XCTAssertTrue(dependencies.fakeURLSession.dataTask_wasCalled)
        XCTAssertEqual(dependencies.fakeURLSession.dataTask_wasCalled_withArgs?.request, dependencies.fakeHTTPRequestEncoder.encode_stubbed)
        XCTAssertTrue(dependencies.fakeURLSession.dataTask_stubbed.resume_wasCalled)

        XCTAssertNotNil(dependencies.fakeURLSession.dataTask_wasCalled_withArgs?.completion)
        let completion = dependencies.fakeURLSession.dataTask_wasCalled_withArgs?.completion
        completion?(nil, nil, HTTPError.statusCode(404))
    
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertFalse(wasSuccess!)
    }
    
    func testSend_encodeSucceeds_dataTaskSucceeds_returnsSucceess() {
        var finalResult: HTTPResponse<RestLikeKit.Empty>?
        var wasSuccess: Bool?
        let completeExpectation = expectation(description: "complete")

        dependencies.fakeHTTPRequestEncoder.encode_stubbed = URLRequest(url: URL(string: "https://example.com")!)
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

        wait(until: dependencies.fakeHTTPRequestEncoder.encode_wasCalled)

        XCTAssertTrue(dependencies.fakeHTTPRequestEncoder.encode_wasCalled)
        XCTAssertTrue(dependencies.fakeURLSession.dataTask_wasCalled)
        XCTAssertEqual(dependencies.fakeURLSession.dataTask_wasCalled_withArgs?.request, dependencies.fakeHTTPRequestEncoder.encode_stubbed)
        XCTAssertTrue(dependencies.fakeURLSession.dataTask_stubbed.resume_wasCalled)

        XCTAssertNotNil(dependencies.fakeURLSession.dataTask_wasCalled_withArgs?.completion)
        let completion = dependencies.fakeURLSession.dataTask_wasCalled_withArgs?.completion
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        completion?(nil, urlResponse, nil)
    
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertTrue(wasSuccess!)
        let expectedResponse = HTTPResponse<RestLikeKit.Empty>(status: 200, url: URL(string: "https://example.com")!, body: Empty(), headers: ["Content-Type": "application/json"])
        XCTAssertEqual(finalResult, expectedResponse)
    }
}
