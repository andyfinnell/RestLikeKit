import Foundation
@testable import RestLikeKit

final class FakeAuthenticationStorage: AuthenticationStorageType {
    var authenticationHeader_wasCalled = false
    var authenticationHeader_wasCalled_withArgs: String?
    var authenticationHeader_stubbed: String?
    func authenticationHeader(for service: String) -> String? {
        authenticationHeader_wasCalled = true
        authenticationHeader_wasCalled_withArgs = service
        return authenticationHeader_stubbed
    }
}
