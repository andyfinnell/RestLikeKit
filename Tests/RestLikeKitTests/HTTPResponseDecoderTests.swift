import Foundation
import XCTest
@testable import RestLikeKit

final class HTTPResponseDecoderTests: XCTestCase {
    var subject: HTTPResponseDecoder!
    
    override func setUp() {
        super.setUp()
        subject = HTTPResponseDecoder()
    }
    
    func testDecode_withError() {
        XCTAssertThrowsError(try subject.decode(HTTPRawResponse(urlResponse: nil, body: nil, error: HTTPError.emptyBody, shouldRedactResponseBody: false), into: HTTPResponse<Empty>.Format.empty))
    }
    
    func testDecode_withNoURLResponse() {
        XCTAssertThrowsError(try subject.decode(HTTPRawResponse(urlResponse: nil, body: nil, error: nil, shouldRedactResponseBody: false), into: HTTPResponse<Empty>.Format.empty))
    }
    
    func testDecode_withErrorStatusCode() {
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: "1.1", headerFields: [:])
        XCTAssertThrowsError(try subject.decode(HTTPRawResponse(urlResponse: urlResponse, body: nil, error: nil, shouldRedactResponseBody: false), into: HTTPResponse<Empty>.Format.empty))
    }
    
    func testDecode_withNoneFormat() {
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "1.1", headerFields: ["frank": "bob", "jim": "fred"])
        do {
            let response = try subject.decode(HTTPRawResponse(urlResponse: urlResponse, body: nil, error: nil, shouldRedactResponseBody: false ), into: HTTPResponse<Empty>.Format.empty)
            XCTAssertEqual(response.status, 200)
            XCTAssertEqual(response.body, Empty())
            XCTAssertEqual(response.headers["frank"], "bob")
            XCTAssertEqual(response.headers["jim"], "fred")
        } catch {
            XCTFail("caught unexpected error")
        }
    }
    
    struct TestPayload: Codable, Equatable {
        let id: Int
        let name: String
    }
    
    func testDecode_withJsonFormat() {
        let urlResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: "1.1", headerFields: ["frank": "bob", "jim": "fred"])
        do {
            let testData = try JSONEncoder.standard.encode(TestPayload(id: 5, name: "Bob"))
            let response = try subject.decode(HTTPRawResponse(urlResponse: urlResponse, body: testData, error: nil, shouldRedactResponseBody: false), into: HTTPResponse<TestPayload>.Format.json)
            XCTAssertEqual(response.status, 200)
            XCTAssertEqual(response.body, TestPayload(id: 5, name: "Bob"))
            XCTAssertEqual(response.headers["frank"], "bob")
            XCTAssertEqual(response.headers["jim"], "fred")
        } catch {
            XCTFail("caught unexpected error")
        }

    }
}
