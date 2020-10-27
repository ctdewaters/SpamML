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
