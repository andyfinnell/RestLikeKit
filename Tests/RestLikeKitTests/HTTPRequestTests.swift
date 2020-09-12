import Foundation
import XCTest
@testable import RestLikeKit

final class HTTPRequestTests: XCTestCase {
    func testEquals_notSame() {
        let lhs = HTTPRequest<Empty>(method: .get, url: URL(string: "https://example.com")!, headers: [.accept: "application/json"], body: .empty, shouldRedactRequestBody: false, shouldRedactResponseBody: false)
        let rhs = HTTPRequest<Empty>(method: .put, url: URL(string: "https://example.com")!, headers: [.accept: "application/json"], body: .empty, shouldRedactRequestBody: false, shouldRedactResponseBody: false)
        XCTAssertFalse(lhs == rhs)
    }
    
    func testEquals_same() {
        let lhs = HTTPRequest<Empty>(method: .get, url: URL(string: "https://example.com")!, headers: [.accept: "application/json"], body: .empty, shouldRedactRequestBody: false, shouldRedactResponseBody: false)
        let rhs = HTTPRequest<Empty>(method: .get, url: URL(string: "https://example.com")!, headers: [.accept: "application/json"], body: .empty, shouldRedactRequestBody: false, shouldRedactResponseBody: false)
        XCTAssertTrue(lhs == rhs)
    }    
}
