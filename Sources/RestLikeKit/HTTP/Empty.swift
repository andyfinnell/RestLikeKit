import Foundation

public struct Empty: Codable, Hashable {
    public init() {}
    
    public init(from decoder: Decoder) throws {
    }
    
    public func encode(to encoder: Encoder) throws {
        // do nothing
    }
    
    public static func ==(lhs: Empty, rhs: Empty) -> Bool {
        return true
    }
}
