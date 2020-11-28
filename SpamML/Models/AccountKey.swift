//
//  AccountKey.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/28/20.
//

import Foundation
import GTMAppAuth

/// This represents a key to which user account information is stored in the keychain.
/// It is also supplied with the source of the account.
struct AccountKey: Identifiable, Codable {
    let keyString: String
    let sourceRaw: Int
    
    var source: Source { Source.init(rawValue: sourceRaw)! }
    var id: String { keyString }
    
    init(key: String, source: Source) {
        keyString = key
        sourceRaw = source.rawValue
    }
    
    enum Source: Int {
        case google, imap
    }
    
    // MARK: - Authentication Item Retrieval
    
    /// Returns the google authentication stored in the keychain if available.
    /// Otherwise returns `nil`.
    var googleAuthentication: GTMAppAuthFetcherAuthorization? {
        guard source == .google else { return nil }
        return GTMAppAuthFetcherAuthorization(fromKeychainForName: keyString)
    }
    
    /// Returns the IMAP credentials stored in the keychain if available.
    /// Otherwise returns `nil`.
    var imapCredentials: IMAPCredentials? {
        guard source == .imap else { return nil }
        return IMAPCredentials(fromKeychainForKey: keyString)
    }
}

extension Array where Element == AccountKey {
    var accountViewModels: [AccountViewModel] {
        return self.compactMap { AccountViewModel.fromAccountKey(accountKey: $0) }
    }
}
