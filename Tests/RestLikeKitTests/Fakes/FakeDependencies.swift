import Foundation
import RestLikeKit

final class FakeDependencies:
    HasAPI,
    HasAPIConfig,
    HasHTTPClient,
    HasHTTPRequestEncoder,
    HasHTTPResponseDecoder,
    HasURLSessionType,
    HasKeychain,
    HasAuthenticationStorage,
    HasLogger {
    
    lazy var api: APIType = API(dependencies: self)
    
    let apiConfig = APIConfig(baseURL: URL(string: "https://example.com/api/")!, baseHeaders: [.apiKey: "valid-api-key"])
    
    lazy var httpClient: HTTPClientType = HTTPClient(dependencies: self)
    
    var fakeHTTPRequestEncoder = FakeHTTPRequestEncoder()
    var realHTTPRequestEncoder = HTTPRequestEncoder()
    lazy var workingHTTPRequestEncoder: HTTPRequestEncoderType = fakeHTTPRequestEncoder
    var httpRequestEncoder: HTTPRequestEncoderType { workingHTTPRequestEncoder }
    
    lazy var httpResponseDecoder: HTTPResponseDecoderType = HTTPResponseDecoder()
    
    var fakeURLSession = FakeURLSession()
    var urlSession: URLSessionType { fakeURLSession }
        
    var fakeKeychain = FakeKeychain()
    var keychain: KeychainType { fakeKeychain }
        
    let logger: LoggerType = FakeLogger()
    
    var fakeAuthenticationStorage = FakeAuthenticationStorage()
    var authenticationStorage: AuthenticationStorageType { fakeAuthenticationStorage }
}
