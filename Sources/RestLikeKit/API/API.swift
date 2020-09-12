import Foundation
import Combine

public enum ResourceVerb {
    case index, show, create, update, delete
}

public protocol ResourceRequest {
    associatedtype ParameterType: Encodable & Equatable
    associatedtype ResourceType: Decodable & Equatable
    
    var verb: ResourceVerb { get }
    var path: String { get }
    var parameters: ParameterType { get }
    var shouldRedactRequestBody: Bool { get }
    var shouldRedactResponseBody: Bool { get }
}

public extension ResourceRequest {
    var shouldRedactRequestBody: Bool { return false }
    var shouldRedactResponseBody: Bool { return false }
}

enum APIError: Error {
    case badUrl
}

public protocol APIType {
    var service: String? { get }
    
    func call<T: ResourceRequest>(_ request: T) -> AnyPublisher<T.ResourceType, Error> where T.ResourceType == Empty
    func call<T: ResourceRequest>(_ request: T) -> AnyPublisher<T.ResourceType, Error>
}

public protocol HasAPI {
    var api: APIType { get }
}

public protocol AuthenticationStorageType {
    func authenticationHeader(for service: String) -> String?
}

public protocol HasAuthenticationStorage {
    var authenticationStorage: AuthenticationStorageType { get }
}

public struct API: APIType {
    public typealias Dependencies = HasHTTPClient & HasAPIConfig & HasAuthenticationStorage
    
    private let dependencies: Dependencies
    
    public var service: String? {
        return dependencies.apiConfig.baseURL.host
    }
    
    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    public func call<T: ResourceRequest>(_ request: T) -> AnyPublisher<T.ResourceType, Error> where T.ResourceType == Empty {
        makeRequestPublisher(request).flatMap { request -> AnyPublisher<HTTPResponse<Empty>, Error> in
            let responseFormat = HTTPResponse<T.ResourceType>.Format.empty
            return self.dependencies.httpClient.send(request: request, responseFormat: responseFormat)
                .eraseToAnyPublisher()
        }.map { $0.body }
        .eraseToAnyPublisher()
    }

    public func call<T: ResourceRequest>(_ request: T) -> AnyPublisher<T.ResourceType, Error> {
        makeRequestPublisher(request).flatMap { request -> AnyPublisher<HTTPResponse<T.ResourceType>, Error> in
            let responseFormat = HTTPResponse<T.ResourceType>.Format.json
            return self.dependencies.httpClient.send(request: request, responseFormat: responseFormat)
                .eraseToAnyPublisher()
        }.map { $0.body }
        .eraseToAnyPublisher()
    }

    private func makeRequestPublisher<T: ResourceRequest>(_ request: T) -> AnyPublisher<HTTPRequest<T.ParameterType>, Error> {
        Deferred {
            Future { promise in
                do {
                    let request = try self.makeRequest(request)
                    promise(.success(request))
                } catch let error {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func makeRequest<T: ResourceRequest>(_ request: T) throws -> HTTPRequest<T.ParameterType> {
        let allHeaders = makeHeaders()
        let method = makeMethod(request)
        let (body, queryItems) = try makeParameters(request)
        let url = try makeUrl(request, with: queryItems)
        
        return HTTPRequest(method: method,
                           url: url,
                           headers: allHeaders,
                           body: body,
                           shouldRedactRequestBody: request.shouldRedactRequestBody,
                           shouldRedactResponseBody: request.shouldRedactResponseBody)
    }
    
    private func makeHeaders() -> [HTTPHeader: String] {
        var allHeaders = dependencies.apiConfig.baseHeaders
        allHeaders[.accept] = "application/json"
        if let service = self.service,
            let header = dependencies.authenticationStorage.authenticationHeader(for: service) {
            allHeaders[.authorization] = header
        }
        return allHeaders
    }
    
    private func makeMethod<T: ResourceRequest>(_ request: T) -> HTTPRequest<T.ParameterType>.Method {
        switch request.verb {
        case .create:
            return .post
        case .delete:
            return .delete
        case .index:
            return .get
        case .update:
            return .put
        case .show:
            return .get
        }
    }
    
    private func makeUrl<T: ResourceRequest>(_ request: T, with queryItems: [URLQueryItem]?) throws -> URL {
        guard let relativeUrl = URL(string: request.path, relativeTo: dependencies.apiConfig.baseURL),
            var urlComponents = URLComponents(url: relativeUrl, resolvingAgainstBaseURL: true) else {
                throw APIError.badUrl
        }

        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url?.absoluteURL else {
            throw APIError.badUrl
        }

        return url
    }
    
    private func makeParameters<T: ResourceRequest>(_ request: T) throws -> (body: HTTPRequestBody<T.ParameterType>, queryItems: [URLQueryItem]?) {
        if request.parameters is Empty {
            return (body: .empty, queryItems: nil)
        } else {
            return try makeNonEmptyParameters(request)
        }
    }
    
    private func makeNonEmptyParameters<T: ResourceRequest>(_ request: T) throws -> (body: HTTPRequestBody<T.ParameterType>, queryItems: [URLQueryItem]?) {
        let body: HTTPRequestBody<T.ParameterType>
        let queryItems: [URLQueryItem]?
        switch request.verb {
        case .create:
            body = .json(request.parameters)
            queryItems = nil
        case .delete:
            body = .empty
            queryItems = try makeQueryItems(request)
        case .index:
            body = .empty
            queryItems = try makeQueryItems(request)
        case .update:
            body = .json(request.parameters)
            queryItems = nil
        case .show:
            body = .empty
            queryItems = try makeQueryItems(request)
        }
        return (body: body, queryItems: queryItems)
    }

    
    private func makeQueryItems<T: ResourceRequest>(_ request: T) throws -> [URLQueryItem]? {
        let queryItems = try QueryItemEncoder().encode(request.parameters)
        if queryItems.isEmpty {
            return nil
        } else {
            return queryItems
        }
    }
}
