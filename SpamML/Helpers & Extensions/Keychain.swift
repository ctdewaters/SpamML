//
//  Keychain.swift
//
//
//  Created by Collin DeWaters on 8/2/19.
//

import Foundation

/// `Keychain`: Provides access to the keychain for safe storage of passwords and tokens.
public class Keychain {
    //MARK: - Key
    /// `Keychain.Key`: Represents a key to store a value in the keychain.
    private struct Key {
        static let googleAuthKeys = "googleAuthKeys"
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
            return  self.load(withKey: key)
        }
        set {
            self.save(newValue, forKey: key)
        }
    }
    
    //MARK: - Known Stored Secure Values
    /// The Google auth keys.
    public var googleAuthKeys: [String] {
        set {
            self[Keychain.Key.googleAuthKeys] = newValue.joined(separator: " ")
        }
        get {
            return self[Keychain.Key.googleAuthKeys]?.components(separatedBy: " ") ?? []
        }
    }
    
    //MARK: - Keychain Queries
    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
    
    
    /// Saves a string to the keychain, with a given key.
    /// - Parameter string: The string to save in the keychain.
    /// - Parameter key: The key, with which to save the string in the keychain.
    private func save(_ string: String?, forKey key: String) {
        let query = self.keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
            }
            else {
                SecItemDelete(query)
            }
        }
        else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                SecItemAdd(query, nil)
            }
        }
    }
    
    /// Loads a string from the keychain, with a given key.
    /// - Parameter key: The key, from which to load a string from the keychain.
    private func load(withKey key: String) -> String? {
        let query = self.keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard let resultsDict = result as? NSDictionary, let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data, status == noErr else {
                return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }
}

