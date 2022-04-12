//
//  KeychainService.swift
//  Forum
//
//  Created by Frank V on 2022/4/13.
//

import Foundation

class KeychainService {
    
    func saveRefreshToken(_ token: String) {
        let token = token.data(using: .utf8)!
        let query: [String:Any] = [kSecClass as String: kSecClassKey, kSecAttrApplicationTag as String: "discu2RefreshToken", kSecValueData as String: token]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { return }
    }
    
    func readRefreshToken() -> String? {
        let query: [String:Any] = [kSecClass as String: kSecClassKey, kSecAttrApplicationTag as String: "discu2RefreshToken", kSecMatchLimit as String: kSecMatchLimitOne, kSecReturnData as String: kCFBooleanTrue!]
        
        var readData: AnyObject? = nil
        let _ = SecItemCopyMatching(query as CFDictionary, &readData)
        
        guard let data = readData as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteRefreshToken() {
        let spec: NSDictionary = [kSecClass: kSecClassKey]
        SecItemDelete(spec)
    }
}
