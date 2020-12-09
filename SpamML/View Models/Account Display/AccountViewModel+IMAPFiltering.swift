//
//  AccountViewModel+IMAPFiltering.swift
//  SpamML
//
//  Created by Collin DeWaters on 12/2/20.
//

import MailCore
import CoreML

extension AccountViewModel {
    func updateFilteredEmails() {
        guard let imapSession = imapCredentials?.createMailCoreSession(), !isRefreshingEmails else { return }
        
        isRefreshingEmails = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let uids = MCOIndexSet(range: MCORange(location: 1, length: .max))
            self?.retrieveUnreadEmails(withSession: imapSession, uids: uids) { [weak self] messages in
                let spamEmails = self?.spamFilter(imapMessages: messages) ?? []
                self?.flaggedEmails = spamEmails.map { $0.emailViewModel }
            }
        }
    }
    
    /// Returns the messages marked as spam by the machine learning model from a given array of `MCOIMAPMessage` instances.
    private func spamFilter(imapMessages: [MCOIMAPMessage]) -> [MCOIMAPMessage] {
        guard let emailSpamClassifier = try? EmailSpamClassifier(configuration: MLModelConfiguration()) else { return [] }
        
        let inputs = imapMessages.map { $0.spamClassifierInput }
        
        let outputs = (try? emailSpamClassifier.predictions(inputs: inputs)) ?? []
        
        var spamMessages = [MCOIMAPMessage]()
        for i in 0..<outputs.count {
            let output = outputs[i]
            
            if output.label == "spam" {
                let message = imapMessages[i]
                
                // Insert at the beginning to re-sort from newest to oldest.
                spamMessages.insert(message, at: 0)
            }
        }
        
        return spamMessages
    }
    
    /// Fetches all unread emails from the given `MCOIMAPSession` in a given range.
    private func retrieveUnreadEmails(withSession session: MCOIMAPSession,
                                      uids: MCOIndexSet? = MCOIndexSet(range: MCORange(location: 1, length: .max)),
                                      withCompletion completion: @escaping ([MCOIMAPMessage])->Void) {
        
        let requestKind: MCOIMAPMessagesRequestKind = [.flags, .fullHeaders]
        let fetchOperation = session.fetchMessagesOperation(withFolder: "INBOX", requestKind: requestKind, uids: uids)
        
        // Fetch the messages in the UID set.
        fetchOperation?.start { [weak self] error, messages, indexSet in
            guard error == nil, let messages = messages else { completion([]); print(error?.localizedDescription ?? ""); return }
            let unread = messages
            
            // Update the last fetched UID for the IMAP Configuration
            let lastUID = UInt64(messages.last?.uid ?? 1)
            self?.imapCredentials?.lastUIDFetched = lastUID
            
            completion(unread)
        }
    }
}

private extension MCOIMAPMessage {
    var spamClassifierInput: EmailSpamClassifierInput {
        return EmailSpamClassifierInput(text: header.subject ?? "Empty Subject" )
    }
}
