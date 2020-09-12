import Foundation
@testable import RestLikeKit

extension ResourceRequest {
    func expectedRequestBodyData() -> Data? {
        if parameters is Empty {
            return nil
        } else {
            return try! JSONEncoder.standard.encode(parameters)
        }
    }
    
    func expectedResponseBodyData<T: Encodable>(response: T) -> Data? {
        if response is Empty {
            return nil
        } else {
            return try! JSONEncoder.standard.encode(response)
        }
    }
}
