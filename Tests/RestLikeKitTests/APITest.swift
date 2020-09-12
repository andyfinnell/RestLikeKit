import Foundation
import Combine
import XCTest
@testable import RestLikeKit

final class APITest: XCTestCase {
    var subject: API!
    var cancellables: Set<AnyCancellable>!
    var urlSession: FakeURLSession!
    var authenticationStorage: FakeAuthenticationStorage!
    
    override func setUp() {
        super.setUp()
        urlSession = FakeURLSession()
        authenticationStorage = FakeAuthenticationStorage()
        
        subject = API(httpClient: HTTPClient(logger: FakeLogger(),
                                             urlSession: urlSession,
                                             httpRequestEncoder: HTTPRequestEncoder(),
                                             httpResponseDecoder: HTTPResponseDecoder()),
                      apiConfig: APIConfig(baseURL: URL(string: "https://example.com/api/")!, baseHeaders: [.apiKey: "valid-api-key"]),
                      authenticationStorage: authenticationStorage)
        cancellables = Set()
    }
    
    func testCall_urlBuildingFails_returnsError() {
        let request = BadURLRequest()
        let completeExpectation = expectation(description: "complete")
        var failure = false
        
        subject.call(request).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                failure = false
            case .failure:
                failure = true
            }
            completeExpectation.fulfill()
        }, receiveValue: { _ in
            // nop
        }).store(in: &cancellables)
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(failure)
    }

    func testCall_urlBuildingSucceeds_hasAuth_httpFails_returnsError() {
        var wasFailure: Bool?
        let request = TestRequest(email: "frank@example.com")
        let completeExpectation = expectation(description: "complete")
        
        authenticationStorage.authenticationHeader_stubbed = "Bearer valid-token"
        subject.call(request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    wasFailure = false
                case .failure:
                    wasFailure = true
                }
                completeExpectation.fulfill()
            }, receiveValue: { _ in
        }).store(in: &cancellables)
        
        wait(until: urlSession.dataTask_wasCalled)
        
        XCTAssertTrue(authenticationStorage.authenticationHeader_wasCalled)
        XCTAssertEqual(authenticationStorage.authenticationHeader_wasCalled_withArgs, "example.com")
        
        XCTAssertTrue(urlSession.dataTask_wasCalled)
        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.request)
        
        let httpRequest = urlSession.dataTask_wasCalled_withArgs?.request
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/login")!)
        XCTAssertEqual(httpRequest?.httpMethod, "POST")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer valid-token")
        XCTAssertEqual(httpRequest?.httpBody, request.expectedRequestBodyData())
        
        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.completion)
        let completion = urlSession.dataTask_wasCalled_withArgs!.completion
        completion(nil, nil, HTTPError.statusCode(404))
    
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertTrue(wasFailure!)
    }
    
    func testCall_urlBuildingSucceeds_hasAuth_httpSucceeds_returnsValue() {
        var finalResult: String?
        let request = TestRequest(email: "frank@example.com")
        let completeExpectation = expectation(description: "complete")

        authenticationStorage.authenticationHeader_stubbed = "Bearer valid-token"
        subject.call(request)
            .sink(receiveCompletion: { completion in
                completeExpectation.fulfill()
            }, receiveValue: { result in
                finalResult = result.token
            }).store(in: &cancellables)
        
        wait(until: urlSession.dataTask_wasCalled)

        XCTAssertTrue(authenticationStorage.authenticationHeader_wasCalled)
        XCTAssertEqual(authenticationStorage.authenticationHeader_wasCalled_withArgs, "example.com")

        XCTAssertTrue(urlSession.dataTask_wasCalled)
        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.request)

        let httpRequest = urlSession.dataTask_wasCalled_withArgs?.request
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/login")!)
        XCTAssertEqual(httpRequest?.httpMethod, "POST")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer valid-token")
        XCTAssertEqual(httpRequest?.httpBody, request.expectedRequestBodyData())

        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.completion)
        let completion = urlSession.dataTask_wasCalled_withArgs!.completion
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com/api/login")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        let responseData = request.expectedResponseBodyData(response: TestRequest.ResourceType(token: "valid-token"))
        completion(responseData, urlResponse, nil)
        
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertEqual(finalResult, "valid-token")
    }

    func testCall_urlBuildingSucceeds_noAuth_httpSucceeds_returnsValue() {
        var finalResult: String?
        let request = TestRequest(email: "frank@example.com")
        let completeExpectation = expectation(description: "complete")

        authenticationStorage.authenticationHeader_stubbed = nil
        subject.call(request)
            .sink(receiveCompletion: { completion in
                completeExpectation.fulfill()
            }, receiveValue: { result in
                finalResult = result.token
            }).store(in: &cancellables)
        
        wait(until: urlSession.dataTask_wasCalled)

        XCTAssertTrue(authenticationStorage.authenticationHeader_wasCalled)
        XCTAssertEqual(authenticationStorage.authenticationHeader_wasCalled_withArgs, "example.com")

        XCTAssertTrue(urlSession.dataTask_wasCalled)
        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.request)

        let httpRequest = urlSession.dataTask_wasCalled_withArgs?.request
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/login")!)
        XCTAssertEqual(httpRequest?.httpMethod, "POST")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertNil(httpRequest?.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual(httpRequest?.httpBody, request.expectedRequestBodyData())

        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.completion)
        let completion = urlSession.dataTask_wasCalled_withArgs!.completion
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com/api/login")!, statusCode: 200, httpVersion: "1.1", headerFields: ["content-type": "application/json"])
        let responseData = request.expectedResponseBodyData(response: TestRequest.ResourceType(token: "valid-token"))
        completion(responseData, urlResponse, nil)
        
        waitForExpectations(timeout: 5.0, handler: nil)

        XCTAssertEqual(finalResult, "valid-token")
    }

    func testShow() {
        let request = ShowRequest(d: "123")

        authenticationStorage.authenticationHeader_stubbed = "Bearer valid-token"
        subject.call(request).sink(receiveCompletion: { _ in
            
        }, receiveValue: { _ in
            
        }).store(in: &cancellables)
    
        wait(until: urlSession.dataTask_wasCalled)

        XCTAssertTrue(urlSession.dataTask_wasCalled)
        XCTAssertNotNil(urlSession.dataTask_wasCalled_withArgs?.request)

        let httpRequest = urlSession.dataTask_wasCalled_withArgs?.request
        XCTAssertEqual(httpRequest?.url, URL(string: "https://example.com/api/message?d=123")!)
        XCTAssertEqual(httpRequest?.httpMethod, "GET")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "accept"), "application/json")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "x-api-key"), "valid-api-key")
        XCTAssertEqual(httpRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer valid-token")
        XCTAssertNil(httpRequest?.httpBody)
    }
}

private struct TestRequest: ResourceRequest {
    struct Request: Encodable, Equatable {
        let email: String
    }
    
    struct ResourceType: Encodable, Decodable, Equatable {
        let token: String
    }
    
    let verb = ResourceVerb.create
    let path = "login"
    let parameters: Request
    
    init(email: String) {
        self.parameters = Request(email: email)
    }
}

private struct BadURLRequest: ResourceRequest {
    typealias ResourceType = RestLikeKit.Empty

    let verb = ResourceVerb.show
    let path = ""
    let parameters = Empty()
}

private struct ShowRequest: ResourceRequest {
    struct Request: Encodable, Equatable {
        let d: String?
    }
    
    struct ResourceType: Encodable, Decodable, Equatable {
        let message: String
    }
    
    let verb = ResourceVerb.show
    let path = "message"
    let parameters: Request
    
    init(d: String?) {
        self.parameters = Request(d: d)
    }
}
