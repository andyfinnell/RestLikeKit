import Foundation
import BaseKit
@testable import RestLikeKit

final class FakeKeychain: KeychainType {
    var password_wasCalled = false
    var password_wasCalled_withArgs: (service: String, account: String)?
    var password_stubbed: String?
    func password(service: String, account: String) -> String? {
        password_wasCalled = true
        password_wasCalled_withArgs = (service: service, account: account)
        return password_stubbed
    }
    
    var set_wasCalled = false
    var set_wasCalled_withArgs: (password: String, service: String, account: String)?
    func set(password: String, service: String, account: String) {
        set_wasCalled = true
        set_wasCalled_withArgs = (password: password, service: service, account: account)
    }
    
    var deletePassword_wasCalled = false
    var deletePassword_wasCalled_withArgs: (service: String, account: String)?
    func deletePassword(service: String, account: String) {
        deletePassword_wasCalled = true
        deletePassword_wasCalled_withArgs = (service: service, account: account)
    }

}

