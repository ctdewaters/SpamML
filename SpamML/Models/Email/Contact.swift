//
//  Contact.swift
//  SpamML
//
//  Created by Collin DeWaters on 12/13/20.
//

import MailCore

/// Represents a contact associated with an `Email` instance.
struct Contact {
    let displayName: String?
    let emailAddress: String?
}

// MARK: - Building From MailCore
extension MCOAddress {
    var contact: Contact {
        Contact(displayName: displayName ?? nil, emailAddress: mailbox ?? nil)
    }
}
