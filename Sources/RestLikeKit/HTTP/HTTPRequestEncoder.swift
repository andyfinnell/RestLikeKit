import Foundation

public protocol HTTPRequestEncoderType {
    func encode<T>(request: HTTPRequest<T>) throws -> URLRequest
}

public protocol HasHTTPRequestEncoder {
    var httpRequestEncoder: HTTPRequestEncoderType { get }
}

public struct HTTPRequestEncoder: HTTPRequestEncoderType {
    public init() {}
    
    public func encode<T>(request: HTTPRequest<T>) throws -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        for header in request.headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key.rawValue)
        }
        switch request.body {
        case .empty:
            urlRequest.httpBody = nil
        case .json(let value):
            urlRequest.httpBody = try JSONEncoder.standard.encode(value)
            urlRequest.setValue("application/json", forHTTPHeaderField: HTTPHeader.contentType.rawValue)
        }
        return urlRequest
    }
}
