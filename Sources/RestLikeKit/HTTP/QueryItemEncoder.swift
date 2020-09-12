import Foundation

struct QueryItemEncoder {
    func encode<E: Encodable>(_ encodable: E) throws -> [URLQueryItem] {
        let data = QueryItemData()
        let encoder = ItemEncoder(data: data, codingPath: [])
        try encodable.encode(to: encoder)
        return data.queryItems
    }
}

private class QueryItemData {
    private(set) var queryItems = [URLQueryItem]()
    
    func setString(_ value: String?, forPath codingPath: [CodingKey]) {
        let item = URLQueryItem(name: key(from: codingPath), value: value)
        queryItems.append(item)
    }
    
    private func key(from codingPath: [CodingKey]) -> String {
        return codingPath.reduce("") { sum, key -> String in
            let keyString = stringify(key)
            if sum.isEmpty {
                return keyString
            } else {
                return sum + "[\(keyString)]"
            }
        }
    }
    
    private func stringify(_ codingKey: CodingKey) -> String {
        if codingKey.intValue != nil {
            return ""
        } else {
            return codingKey.stringValue
        }
    }
}

private struct ItemEncoder: Encoder {
    let codingPath: [CodingKey]
    let userInfo = [CodingUserInfoKey : Any]()
    
    private let data: QueryItemData
    
    init(data: QueryItemData, codingPath: [CodingKey]) {
        self.data = data
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(ItemKeyedContainer(data: data, codingPath: codingPath))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return ItemUnkeyedContainer(data: data, codingPath: codingPath)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return ItemSingleValueContainer(data: data, codingPath: codingPath)
    }
}

private class ItemKeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    let codingPath: [CodingKey]
    private let data: QueryItemData
    
    init(data: QueryItemData, codingPath: [CodingKey]) {
        self.data = data
        self.codingPath = codingPath
    }

    func encodeNil(forKey key: K) throws {
        
    }
    
    func encode(_ value: Bool, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: String, forKey key: K) throws {
        data.setString(value, forPath: codingPath + [key])
    }
    
    func encode(_ value: Double, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: Float, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: Int, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: Int8, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: Int16, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: Int32, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: Int64, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: UInt, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: UInt8, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: UInt16, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: UInt32, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode(_ value: UInt64, forKey key: K) throws {
        data.setString(String(describing: value), forPath: codingPath + [key])
    }
    
    func encode<T: Encodable>(_ value: T, forKey key: K) throws {
        let encoder = ItemEncoder(data: data, codingPath: codingPath + [key])
        try value.encode(to: encoder)
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> {
        return KeyedEncodingContainer(ItemKeyedContainer<NestedKey>(data: data, codingPath: codingPath + [key]))
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        return ItemUnkeyedContainer(data: data, codingPath: codingPath + [key])
    }
    
    func superEncoder() -> Encoder {
        return ItemEncoder(data: data, codingPath: codingPath)
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        return ItemEncoder(data: data, codingPath: codingPath + [key])
    }
}

private struct IndexKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        return nil
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(describing: intValue)
    }
    
    init(_ intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(describing: intValue)
    }
}

private class ItemUnkeyedContainer: UnkeyedEncodingContainer {
    
    let codingPath: [CodingKey]
    var count = 0
    private let data: QueryItemData
    private var index: IndexKey {
        return IndexKey(count)
    }
    
    init(data: QueryItemData, codingPath: [CodingKey]) {
        self.data = data
        self.codingPath = codingPath
    }
    
    func encodeNil() throws {
        
    }
    
    func encode(_ value: Bool) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: String) throws {
        defer { count += 1 }
        data.setString(value, forPath: codingPath + [index])
    }
    
    func encode(_ value: Double) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: Float) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: Int) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: Int8) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: Int16) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: Int32) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: Int64) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: UInt) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: UInt8) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: UInt16) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: UInt32) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode(_ value: UInt64) throws {
        defer { count += 1 }
        data.setString(String(describing: value), forPath: codingPath + [index])
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        defer { count += 1 }
        let encoder = ItemEncoder(data: data, codingPath: codingPath + [index])
        try value.encode(to: encoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        defer { count += 1 }
        return KeyedEncodingContainer(ItemKeyedContainer<NestedKey>(data: data, codingPath: codingPath + [index]))
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        defer { count += 1 }
        return ItemUnkeyedContainer(data: data, codingPath: codingPath + [index])
    }
    
    func superEncoder() -> Encoder {
        defer { count += 1 }
        return ItemEncoder(data: data, codingPath: codingPath + [index])
    }
}

private class ItemSingleValueContainer: SingleValueEncodingContainer {
    let codingPath: [CodingKey]
    private let data: QueryItemData
    
    init(data: QueryItemData, codingPath: [CodingKey]) {
        self.data = data
        self.codingPath = codingPath
    }
    
    func encodeNil() throws {
        // noop
    }
    
    func encode(_ value: Bool) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: String) throws {
        data.setString(value, forPath: codingPath)
    }
    
    func encode(_ value: Double) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: Float) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: Int) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: Int8) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: Int16) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: Int32) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: Int64) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: UInt) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: UInt8) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: UInt16) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: UInt32) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode(_ value: UInt64) throws {
        data.setString(String(describing: value), forPath: codingPath)
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = ItemEncoder(data: data, codingPath: codingPath)
        try value.encode(to: encoder)
    }
}
