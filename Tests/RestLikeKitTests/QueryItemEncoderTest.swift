import Foundation
import XCTest
@testable import RestLikeKit

final class QueryItemEncoderTest: XCTestCase {
    var subject: QueryItemEncoder!

    override func setUp() {
        super.setUp()
        subject = QueryItemEncoder()
    }
    
    func testEncodingQueryItems() throws {
        let queryItems = try subject.encode(TestParameters1())
        let expectedItems = [
            URLQueryItem(name: "name", value: "frank"),
            URLQueryItem(name: "nestedData[isOn]", value: "true"),
            URLQueryItem(name: "nestedData[foo]", value: "42"),
            URLQueryItem(name: "array[]", value: "one"),
            URLQueryItem(name: "array[]", value: "two"),
            URLQueryItem(name: "array[]", value: "three")
        ]
        XCTAssertEqual(queryItems, expectedItems)
    }
}

private struct NestedData: Encodable {
    let isOn = true
    let foo = 42
}

private struct TestParameters1: Encodable {
    let name = "frank"
    let nestedData = NestedData()
    let array = ["one", "two", "three"]
}
