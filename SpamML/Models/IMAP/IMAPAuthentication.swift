//
//  IMAPAuthentication.swift
//  SpamML
//
//  Created by Collin DeWaters on 10/26/20.
//

import Foundation
import MailCore

struct IMAPAuthentication: Codable, Equatable {
    let username: String
    let password: String
    let port: Int
    let hostname: String
    
    // MARK: - MailCore Session Creation
    func createMailCoreSession() -> MCOIMAPSession {
        let session = MCOIMAPSession()
        session.username = username
        session.password = password
        session.port = UInt32(port)
        session.hostname = hostname
        session.connectionType = .TLS
        return session
    }
    
    static func == (lhs: IMAPAuthentication, rhs: IMAPAuthentication) -> Bool { lhs.username == rhs.username }
}
