import Foundation
import Combine

public protocol HTTPClientType {
    func send<T, R>(request: HTTPRequest<T>, responseFormat: HTTPResponse<R>.Format) -> AnyPublisher<HTTPResponse<R>, Error>
}

public protocol HasHTTPClient {
    var httpClient: HTTPClientType { get }
}

public final class HTTPClient: HTTPClientType {
    public typealias Dependencies = HasHTTPRequestEncoder & HasHTTPResponseDecoder
        & HasURLSessionType & HasLogger
    
    private let dependencies: Dependencies
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public func send<T, R>(request: HTTPRequest<T>, responseFormat: HTTPResponse<R>.Format) -> AnyPublisher<HTTPResponse<R>, Error> {
        let dependencies = self.dependencies
        return Deferred {
            Future { promise in
                var dataTask: URLSessionDataTaskType?
                do {
                    dependencies.logger.debug(request, tag: .http)
                    let urlRequest = try dependencies.httpRequestEncoder.encode(request: request)
                    dataTask = dependencies.urlSession.dataTask(request: urlRequest) { maybeData, maybeUrlResponse, maybeError in
                        do {
                            let rawResponse = HTTPRawResponse(urlResponse: maybeUrlResponse, body: maybeData, error: maybeError, shouldRedactResponseBody: request.shouldRedactResponseBody)
                            dependencies.logger.debug(rawResponse, tag: .http)
                            let response = try dependencies.httpResponseDecoder.decode(rawResponse, into: responseFormat)
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
