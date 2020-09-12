import Foundation

public enum HTTPHeader: String, Hashable {
    case apiKey = "x-api-key"
    case authorization = "authorization"
    case accept = "accept"
    case contentType = "content-type"
}
