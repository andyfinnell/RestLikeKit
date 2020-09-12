import Foundation
import Security

public protocol KeychainType {
    func password(service: String, account: String) -> String?
    func set(password: String, service: String, account: String)
    func deletePassword(service: String, account: String)
}

public protocol HasKeychain {
    var keychain: KeychainType { get }
}

public struct Keychain: KeychainType {
    public init() {}
    
    public func password(service: String, account: String) -> String? {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: account,
                     kSecAttrService: service,
                     kSecReturnData: kCFBooleanTrue!,
                     kSecMatchLimit: kSecMatchLimitOne]
        

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard status == noErr else {
            return nil
        }
        
        guard let passwordData = queryResult as? Data else {
            return nil
        }
        
        return String(data: passwordData, encoding: .utf8)
    }
    
    public func set(password: String, service: String, account: String) {
        guard let passwordData = password.data(using: .utf8) else {
            return
        }
        
        if let _ = self.password(service: service, account: account) {
            update(passwordData: passwordData, service: service, account: account)
        } else {
            add(passwordData: passwordData, service: service, account: account)
        }
    }
    
    public func deletePassword(service: String, account: String) {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrAccount: account,
                                      kSecAttrService: service,
                                      kSecAttrLabel: service]
        SecItemDelete(query as CFDictionary)
    }
    
    private func update(passwordData: Data, service: String, account: String) {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrAccount: account,
                                      kSecAttrService: service,
                                      kSecAttrLabel: service]
        let newAttributes = [kSecValueData: passwordData]
        SecItemUpdate(query as CFDictionary, newAttributes as CFDictionary)
    }
    
    private func add(passwordData: Data, service: String, account: String) {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                      kSecAttrAccount: account,
                                      kSecAttrService: service,
                                      kSecAttrLabel: service,
                                      kSecValueData: passwordData]
        
        let err = SecItemAdd(query as CFDictionary, nil)
        
        if err == errSecDuplicateItem  {
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }

}
