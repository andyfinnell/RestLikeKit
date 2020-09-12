import Foundation

public struct APIConfig {
    public let baseURL: URL
    public let baseHeaders: [HTTPHeader: String]
    
    public init(baseURL: URL, baseHeaders: [HTTPHeader: String]) {
        self.baseURL = baseURL
        self.baseHeaders = baseHeaders
    }
}

public protocol HasAPIConfig {
    var apiConfig: APIConfig { get }
}
