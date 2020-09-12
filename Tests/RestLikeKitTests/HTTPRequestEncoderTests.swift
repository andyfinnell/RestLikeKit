import Foundation
import XCTest
@testable import RestLikeKit

final class HTTPRequestEncoderTests: XCTestCase {
    var subject: HTTPRequestEncoder!
    
    override func setUp() {
        super.setUp()
        subject = HTTPRequestEncoder()
    }
    
    func testEncode_noBody() {
        let httpRequest = HTTPRequest<Empty>(method: .get,
                                             url: URL(string: "https://example.com")!,
                                             headers: [.accept: "application/json"],
                                             body: .empty,
                                             shouldRedactRequestBody: false,
                                             shouldRedactResponseBody: false)
        
        do {
            let urlRequest = try subject.encode(request: httpRequest)
            XCTAssertEqual(urlRequest.url, URL(string: "https://example.com")!)
            XCTAssertEqual(urlRequest.httpMethod, "GET")
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "accept"), "application/json")
            XCTAssertNil(urlRequest.httpBody)
        } catch {
            XCTFail("caught an unexpected exception")
        }
    }
    
    struct TestPayload: Encodable, Hashable {
        let id: Int
        let name: String
    }
    
    func testEncode_jsonBody() {
        let httpRequest = HTTPRequest<TestPayload>(method: .post,
                                             url: URL(string: "https://example.com")!,
                                             headers: [.accept: "application/json"],
                                             body: .json(TestPayload(id: 1, name: "frank")),
                                             shouldRedactRequestBody: false,
                                             shouldRedactResponseBody: false)
        do {
            let urlRequest = try subject.encode(request: httpRequest)
            XCTAssertEqual(urlRequest.url, URL(string: "https://example.com")!)
            XCTAssertEqual(urlRequest.httpMethod, "POST")
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "accept"), "application/json")
            XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "content-type"), "application/json")
            let expectedBody = try JSONEncoder.standard.encode(TestPayload(id: 1, name: "frank"))
            XCTAssertEqual(urlRequest.httpBody, expectedBody)
        } catch {
            XCTFail("caught an unexpected exception")
        }
    }
}
