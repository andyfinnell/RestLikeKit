import Foundation

// Nesting this data type inside of HTTPRequest blows up the Swift runtime
//  with a "cyclic metadata dependency detected, aborting" error
enum HTTPRequestBody<T: Encodable & Equatable>: Equatable {
    case empty
    case json(T)
}
