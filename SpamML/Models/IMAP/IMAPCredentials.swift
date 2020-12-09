//
//  IMAPCredentials.swift
//  SpamML
//
//  Created by Collin DeWaters on 10/26/20.
//

import Foundation
import MailCore

struct IMAPCredentials: Codable, Equatable {
    let username: String
    let password: String
    let port: UInt32
    let hostname: String
    
    var identifier: String { username + hostname }
    
    var lastUIDFetched: UInt64 {
        set {
            SpamMLUserDefaults.lastRetrievedUIDs[identifier] = newValue
        }
        get {
            SpamMLUserDefaults.lastRetrievedUIDs[identifier] ?? 1
        }
    }
    
    // MARK: - Initializers
    init(username: String, password: String, port: UInt32, hostname: String) {
        self.username = username
        self.password = password
        self.port = port
        self.hostname = hostname
    }

    /// Initalizes an `IMAPCredentials` instance from the keychain for a given key.
    /// If not present, `nil` is returned.
    init?(fromKeychainForKey key: String) {
        guard let credentials = Keychain.shared.loadIMAPCredentials(forKey: key) else { return nil }
        self = credentials
    }
    
    // MARK: - MailCore Session Creation
    func createMailCoreSession() -> MCOIMAPSession {
        let session = MCOIMAPSession()
        session.username = username
        session.password = password
        session.port = port
        session.hostname = hostname
        session.connectionType = .TLS
        return session
    }
    
    static func == (lhs: IMAPCredentials, rhs: IMAPCredentials) -> Bool { lhs.username == rhs.username }
}
