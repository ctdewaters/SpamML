//
//  Keychain.swift
//
//
//  Created by Collin DeWaters on 8/2/19.
//

import Foundation
import GTMAppAuth

/// `Keychain`: Provides access to the keychain for safe storage of passwords and tokens.
public class Keychain {
    //MARK: - Key
    /// `Keychain.Key`: Represents a key to store a value in the keychain.
    private struct Key {
        static let accountKeys = "accountKeys"
        static let googleAuthKeys = "googleAuthKeys"
        static let customIMAPAuthKeys = "customIMAPAuthKeys"
    }
    
    //MARK: - Error
    public enum KeyError: Error {
        case notAuthenticated, encryptionKeyNotSet
    }
    
    //MARK: - Properties
    public static let shared = Keychain()
    
    //MARK: - Initialization
    private init() {}
    
    //MARK: - Subscript
    public subscript(key: String) -> String? {
        get {
            return self.loadString(withKey: key)
        }
        set {
            self.saveString(newValue, forKey: key)
        }
    }
        
    //MARK: - Keychain Queries
    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleWhenUnlocked, forKey: kSecAttrAccessible as String)
        return result
    }
    
    
    /// Saves a string to the keychain, with a given key.
    /// - Parameter string: The string to save in the keychain.
    /// - Parameter key: The key, with which to save the string in the keychain.
    private func saveString(_ string: String?, forKey key: String) {
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)
        saveData(objectData, forKey: key)
    }
    
    /// Loads a string from the keychain, with a given key.
    /// - Parameter key: The key, from which to load a string from the keychain.
    private func loadString(withKey key: String) -> String? {
        guard let data = loadData(withKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Saves data  to the keychain, with a given key.
    /// - Parameter data: The data to save in the keychain.
    /// - Parameter key: The key, with which to save the data in the keychain.
    private func saveData(_ data: Data?, forKey key: String) {
        let query = self.keychainQuery(withKey: key)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = data {
                SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
            }
            else {
                SecItemDelete(query)
            }
        }
        else {
            if let dictData = data {
                query.setValue(dictData, forKey: kSecValueData as String)
                SecItemAdd(query, nil)
            }
        }
    }
    
    /// Loads data from the keychain, with a given key.
    /// - Parameter key: The key, from which to load data from the keychain.
    private func loadData(withKey key: String) -> Data? {
        let query = self.keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard let resultsDict = result as? NSDictionary, let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data, status == noErr else {
                return nil
        }
        return resultsData
    }
}

// MARK: - Account Keys
extension Keychain {
    var accountKeys: [AccountKey] {
        set {
            let data = try? JSONEncoder().encode(newValue)
            saveData(data, forKey: Key.accountKeys)
        }
        get {
            guard let data = loadData(withKey: Key.accountKeys) else { return [] }
            return (try? JSONDecoder().decode([AccountKey].self, from: data)) ?? []
        }
    }
}

//MARK: - Google Sign In Properties
extension Keychain {
    fileprivate func save(userInfo: GoogleUserInfo?, forAuthorization auth: GTMAppAuthFetcherAuthorization) {
        guard var key = auth.userID else { return }
        key += "-USERINFO"
        let userInfoData = try? JSONEncoder().encode(userInfo)
        saveData(userInfoData, forKey: key)
    }
    
    fileprivate func loadUserInfo(forAuthorization auth: GTMAppAuthFetcherAuthorization) -> GoogleUserInfo? {
        guard var key = auth.userID else { return nil }
        key += "-USERINFO"
        guard let data = loadData(withKey: key) else { return nil }
        return try? JSONDecoder().decode(GoogleUserInfo.self, from: data)
    }
}

// MARK: - Custom IMAP Account Properties
extension Keychain {
    func save(imapCredentials: IMAPCredentials?, forKey key: String) {
        let data = try? JSONEncoder().encode(imapCredentials)
        
        if let _ = data {
            let accountKey = AccountKey(key: key, source: .imap)
            accountKeys.append(accountKey)
        }
        else {
            accountKeys.removeAll { $0.keyString == key }
        }
        
        saveData(data, forKey: key)
    }
    
    func loadIMAPCredentials(forKey key: String) -> IMAPCredentials? {
        guard let data = loadData(withKey: key) else { return nil }
        return try? JSONDecoder().decode(IMAPCredentials.self, from: data)
    }
}

extension GTMAppAuthFetcherAuthorization {
    var userInfo: GoogleUserInfo? {
        set {
            Keychain.shared.save(userInfo: newValue, forAuthorization: self)
        }
        get {
            Keychain.shared.loadUserInfo(forAuthorization: self)
        }
    }
}
