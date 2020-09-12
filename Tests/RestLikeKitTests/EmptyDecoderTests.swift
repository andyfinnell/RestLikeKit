import Foundation
import XCTest
@testable import RestLikeKit

final class EmptyDecoderTests: XCTestCase {
    var subject: EmptyDecoder!
    
    override func setUp() {
        super.setUp()
        subject = EmptyDecoder()
    }
    
    func testDecode_withEmpty() {
        XCTAssertNoThrow(try subject.decode(Empty.self))
    }
    
    struct TestPayload: Codable {
        let id: Int
        let name: String
    }

    func testDecode_withNoEmpty() {
        XCTAssertThrowsError(try subject.decode(TestPayload.self))
    }
}
