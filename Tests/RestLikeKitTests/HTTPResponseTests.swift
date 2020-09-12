import Foundation
import XCTest
@testable import RestLikeKit

final class HTTPResponseTests: XCTestCase {
    
    func testEquals_notSame() {
        let lhs = HTTPResponse<Empty>(status: 200, url: URL(string: "http://lynxfile.com")!, body: Empty(), headers: ["content-type": "application/json"])
        let rhs = HTTPResponse<Empty>(status: 400, url: URL(string: "http://lynxfile.com")!, body: Empty(), headers: ["content-type": "application/json"])
        XCTAssertFalse(lhs == rhs)
    }
    
    func testEquals_same() {
        let lhs = HTTPResponse<Empty>(status: 200, url: URL(string: "http://lynxfile.com")!, body: Empty(), headers: ["content-type": "application/json"])
        let rhs = HTTPResponse<Empty>(status: 200, url: URL(string: "http://lynxfile.com")!, body: Empty(), headers: ["content-type": "application/json"])
        XCTAssertTrue(lhs == rhs)
    }
}
