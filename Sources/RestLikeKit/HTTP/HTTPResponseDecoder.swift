import Foundation

public protocol HTTPResponseDecoderType {
    func decode<T>(_ rawResponse: HTTPRawResponse, into format: HTTPResponse<T>.Format) throws -> HTTPResponse<T>
}

public protocol HasHTTPResponseDecoder {
    var httpResponseDecoder: HTTPResponseDecoderType { get }
}

public struct HTTPResponseDecoder: HTTPResponseDecoderType {
    public init() {}
    
    public func decode<T>(_ rawResponse: HTTPRawResponse, into format: HTTPResponse<T>.Format) throws -> HTTPResponse<T> {
        if let error = rawResponse.error {
            throw error
        }
        
        guard let urlResponse = rawResponse.urlResponse as? HTTPURLResponse else {
            throw HTTPError.emptyBody
        }
        guard let url = urlResponse.url else {
            throw HTTPError.noUrl
        }
        
        if urlResponse.statusCode >= 400 {
            throw HTTPError.statusCode(urlResponse.statusCode)
        }
        let headers = self.headers(urlResponse: urlResponse)

        let body: T
        switch format {
        case .empty:
            body = try EmptyDecoder().decode(T.self)
        case .json:
            let theData = rawResponse.body ?? Data()
            body = try JSONDecoder.standard.decode(T.self, from: theData)
        }
        
        return HTTPResponse(status: urlResponse.statusCode, url: url, body: body, headers: headers)
    }
    
    private func headers(urlResponse: HTTPURLResponse) -> [String: String] {
        return urlResponse.allHeaderFields.reduce(into: [String: String]()) { headers, keyValue in
            let (key, value) = keyValue
            if let name = key as? String, let headerValue = value as? String {
                headers[name] = headerValue
            }
        }
    }
}
