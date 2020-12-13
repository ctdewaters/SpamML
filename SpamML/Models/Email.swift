//
//  Email.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/13/20.
//

import SwiftUI
import MailCore

/// A global representaiton of an email message, which is created with `GmailController` and `IMAPController`, and can be used with the `MLFilterController`.
struct Email: Identifiable, Hashable {
    let subject: String
    let body: String
    let timestamp: Date
    
    let id = UUID().uuidString
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var timestampString: String {
        Email.timestampFormatter.string(from: timestamp)
    }
}

extension MCOIMAPMessage {
    var email: Email {
        Email(subject: header.subject, body: "This is the body preview", timestamp: Date())
    }
}
