import Foundation
@testable import RestLikeKit

final class FakeURLSessionDataTask: URLSessionDataTaskType {
    var resume_wasCalled = false
    func resume() {
        resume_wasCalled = true
    }
    
    var cancel_wasCalled = false
    func cancel() {
        cancel_wasCalled = true
    }
}
