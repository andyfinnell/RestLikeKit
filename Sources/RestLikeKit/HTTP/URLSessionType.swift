import Foundation

public protocol URLSessionDataTaskType {
    func resume()
    func cancel()
}

public protocol URLSessionType {
    func dataTask(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskType
}

public protocol HasURLSessionType {
    var urlSession: URLSessionType { get }
}

extension URLSessionDataTask: URLSessionDataTaskType {}
extension URLSession: URLSessionType {
    public func dataTask(request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskType {
        return dataTask(with: request, completionHandler: completion)
    }
}
