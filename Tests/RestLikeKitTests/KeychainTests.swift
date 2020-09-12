import Foundation
import XCTest
@testable import RestLikeKit

// We only turn this on for AppKit because iOS requires an entitlement in order
//  to access this keychain. Unfortunately, the Swift Package Management does
//  not provide a way to set entitlements on its test runner app. Therefore
//  these tests will always fail with `errSecMissingEntitlement` on iOS and tvOS.
#if canImport(AppKit)

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

#endif
