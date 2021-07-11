import Foundation
import BaseKit

public struct HTTPRequest<T: Encodable & Equatable>: Equatable {
    enum Method: String, Hashable {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    let method: Method
    let url: URL
    let headers: [HTTPHeader: String]
    let body: HTTPRequestBody<T>
    let shouldRedactRequestBody: Bool
    let shouldRedactResponseBody: Bool
}

extension HTTPRequest: Loggable {
    public func log(_ output: (String) -> Void) {
        output("<== \(method) \(url)")
        for (key, value) in headers {
            let isRedacted = [HTTPHeader.apiKey, .authorization].contains(key)
            let loggableValue = isRedacted ? "<redacted>" : value
            output("<== headers[\(key)]: \(loggableValue)")
        }
        if case let .json(encodable) = body,
            let data = try? JSONEncoder.standard.encode(encodable),
            let string = String(data: data, encoding: .utf8),
            !shouldRedactRequestBody {
            output("<== \(string)")
        }
    }
}
