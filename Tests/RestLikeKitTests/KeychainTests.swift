import Foundation
import XCTest
@testable import RestLikeKit

final class KeychainTests: XCTestCase {
    var subject: Keychain!
    
    override func setUp() {
        super.setUp()
        subject = Keychain()
    }
    
    override func tearDown() {
        super.tearDown()
        subject.deletePassword(service: "service", account: "frank@example.com")
    }
    
    func testPassword_doesNotExist() {
        XCTAssertNil(subject.password(service: "service", account: "frank@example.com"))
    }
    
    func testPassword_exists() {
        subject.set(password: "supersecret", service: "service", account: "frank@example.com")
        XCTAssertEqual(subject.password(service: "service", account: "frank@example.com"), "supersecret")
        subject.deletePassword(service: "service", account: "frank@example.com")
    }
    
    func testSet_doesNotExist() {
        subject.set(password: "supersecret", service: "service", account: "frank@example.com")
        XCTAssertEqual(subject.password(service: "service", account: "frank@example.com"), "supersecret")
        subject.deletePassword(service: "service", account: "frank@example.com")
    }
    
    func testSet_exists() {
        subject.set(password: "compromised", service: "service", account: "frank@example.com")
        subject.set(password: "supersecret", service: "service", account: "frank@example.com")
        XCTAssertEqual(subject.password(service: "service", account: "frank@example.com"), "supersecret")
        subject.deletePassword(service: "service", account: "frank@example.com")
    }
    
    func testDelete() {
        subject.set(password: "supersecret", service: "service", account: "frank@example.com")
        subject.deletePassword(service: "service", account: "frank@example.com")
        XCTAssertNil(subject.password(service: "service", account: "frank@example.com"))
    }
}
