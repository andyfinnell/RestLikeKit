import Foundation
import XCTest
@testable import RestLikeKit

final class EmptyTests: XCTestCase {    
    func test_equals() {
        XCTAssertTrue(Empty() == Empty())
    }
}

