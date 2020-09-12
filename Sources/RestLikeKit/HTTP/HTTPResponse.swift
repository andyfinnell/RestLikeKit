import Foundation

public struct HTTPResponse<T: Decodable & Equatable>: Equatable {
    public enum Format {
        case empty
        case json
    }

    let status: Int
    let url: URL
    let body: T
    let headers: [String: String]
}
