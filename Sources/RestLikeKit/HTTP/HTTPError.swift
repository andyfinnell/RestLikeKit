import Foundation

enum HTTPError: Error {
    case statusCode(Int)
    case emptyBody
    case noUrl
}
