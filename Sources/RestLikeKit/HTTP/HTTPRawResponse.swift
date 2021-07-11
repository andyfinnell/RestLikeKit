import Foundation
import BaseKit

public struct HTTPRawResponse {
    let urlResponse: URLResponse?
    let body: Data?
    let error: Error?
    let shouldRedactResponseBody: Bool
}

extension HTTPRawResponse: Loggable {
    public func log(_ output: (String) -> Void) {
        if let error = error {
            output("==> \(error)")
            return
        }
        
        guard let urlResponse = urlResponse as? HTTPURLResponse,
            let url = urlResponse.url else {
            output("==> <invalid response>")
            return
        }

        output("==> \(urlResponse.statusCode) \(url)")
        let redactedHeaders = Set([HTTPHeader.apiKey, .authorization].map { $0.rawValue.lowercased() })
        for (rawKey, value) in urlResponse.allHeaderFields {
            guard let key = rawKey as? String else { continue }
            
            let isRedacted = redactedHeaders.contains(key.lowercased())
            let loggableValue = isRedacted ? "<redacted>" : value
            output("==> headers[\(key)]: \(loggableValue)")
        }

        if let data = body, let string = String(data: data, encoding: .utf8), !shouldRedactResponseBody {
            output("==> \(string)")
        }
    }
}
