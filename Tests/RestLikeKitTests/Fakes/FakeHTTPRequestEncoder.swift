import Foundation
@testable import RestLikeKit

enum RequestEncoderError: Error {
    case badMojo
}

final class FakeHTTPRequestEncoder: HTTPRequestEncoderType {
    
    var encode_wasCalled = false
    var encode_stubbed: URLRequest?
    func encode<T>(request: HTTPRequest<T>) throws -> URLRequest {
        encode_wasCalled = true
        guard let urlRequest = encode_stubbed else {
            throw RequestEncoderError.badMojo
        }
        
        return urlRequest
    }

}
