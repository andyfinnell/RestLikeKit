import Foundation
import XCTest

extension XCTestCase {
    func wait(until predicate: @autoclosure () -> Bool, timeout: TimeInterval = 5.0) {
        let expirationDate = Date(timeIntervalSinceNow: timeout)
        while Date() < expirationDate && !predicate() {
            RunLoop.main.run(until: Date())
        }
    }
}
