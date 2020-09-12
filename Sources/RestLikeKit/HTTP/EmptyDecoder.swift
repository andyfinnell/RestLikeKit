import Foundation

enum DecoderError: Error {
    case notEmpty
}

struct EmptyDecoder {
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = DevNullDecoder()
        return try type.init(from: decoder)
    }
}

private struct DevNullDecoder: Decoder {
    let codingPath: [CodingKey] = []
    let userInfo: [CodingUserInfoKey : Any] = [:]
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw DecoderError.notEmpty
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DecoderError.notEmpty
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DecoderError.notEmpty
    }
}
