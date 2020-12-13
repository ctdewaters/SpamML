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
    let id: String
    
    // Contact Properties
    let from: Contact
    let to: [Contact]
    let cc: [Contact]
    let bcc: [Contact]
    
    var uid: UInt32 { UInt32(id)! }
    
    // MARK: - Timestamp Formatting
    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var timestampString: String {
        Email.timestampFormatter.string(from: timestamp)
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    static func == (lhs: Email, rhs: Email) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Test Code
extension Email {
    private static let testFromContact = Contact(displayName: "Test Sender", emailAddress: "test@collindewaters.com")
    private static let testToContact = Contact(displayName: "SpamML", emailAddress: "spamml@collindewaters.com")
    
    /// This function is intended to to only be used to create test `Email` instances with SwiftUI previews and unit tests.
    /// Do not use this in production code.
    static func testInstance(subject: String, body: String, id: String) -> Email {
        Email(subject: subject, body: body, timestamp: Date(), id: id, from: testFromContact, to: [testToContact], cc: [], bcc: [])
    }
}
