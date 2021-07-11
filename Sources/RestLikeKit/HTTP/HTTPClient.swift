import Foundation
import BaseKit
import Combine

public protocol HTTPClientType {
    func send<T, R>(request: HTTPRequest<T>, responseFormat: HTTPResponse<R>.Format) -> AnyPublisher<HTTPResponse<R>, Error>
}

public protocol HasHTTPClient {
    var httpClient: HTTPClientType { get }
}

public final class HTTPClient: HTTPClientType {
    private let logger: LoggerType
    private let urlSession: URLSessionType
    private let httpRequestEncoder: HTTPRequestEncoderType
    private let httpResponseDecoder: HTTPResponseDecoderType
    
    public init(logger: LoggerType,
                urlSession: URLSessionType,
                httpRequestEncoder: HTTPRequestEncoderType,
                httpResponseDecoder: HTTPResponseDecoderType) {
        self.logger = logger
        self.urlSession = urlSession
        self.httpRequestEncoder = httpRequestEncoder
        self.httpResponseDecoder = httpResponseDecoder
    }
    
    public func send<T, R>(request: HTTPRequest<T>, responseFormat: HTTPResponse<R>.Format) -> AnyPublisher<HTTPResponse<R>, Error> {
        let logger = self.logger
        let urlSession = self.urlSession
        let httpRequestEncoder = self.httpRequestEncoder
        let httpResponseDecoder = self.httpResponseDecoder
        
        return Deferred {
            Future { promise in
                var dataTask: URLSessionDataTaskType?
                do {
                    logger.debug(request, tag: .http)
                    let urlRequest = try httpRequestEncoder.encode(request: request)
                    dataTask = urlSession.dataTask(request: urlRequest) { maybeData, maybeUrlResponse, maybeError in
                        do {
                            let rawResponse = HTTPRawResponse(urlResponse: maybeUrlResponse, body: maybeData, error: maybeError, shouldRedactResponseBody: request.shouldRedactResponseBody)
                            logger.debug(rawResponse, tag: .http)
                            let response = try httpResponseDecoder.decode(rawResponse, into: responseFormat)
                            promise(.success(response))
                        } catch let err {
                            promise(.failure(err))
                        }
                    }
                    dataTask?.resume()
                } catch let err {
                    promise(.failure(err))
                }

            }
        }
        .subscribe(on: DispatchQueue.global(qos: .background))
        .eraseToAnyPublisher()
    }
}
