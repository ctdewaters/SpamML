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
        guard let imapSession = imapCredentials?.createMailCoreSession() else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.retrieveUnreadEmails(withSession: imapSession) { [weak self] messages in
                let spamEmails = self?.spamFilter(imapMessages: messages) ?? []
                self?.flaggedEmails = spamEmails.map { $0.emailViewModel }
            }
        }
    }
    
    private func spamFilter(imapMessages: [MCOIMAPMessage]) -> [MCOIMAPMessage] {
        guard let emailSpamClassifier = try? EmailSpamClassifier(configuration: MLModelConfiguration()) else { return [] }
        
        let inputs = imapMessages.map { $0.spamClassifierInput }
        
        let outputs = (try? emailSpamClassifier.predictions(inputs: inputs)) ?? []
        
        var spamMessages = [MCOIMAPMessage]()
        for i in 0..<outputs.count {
            let output = outputs[i]
            
            if output.label == "spam" {
                let message = imapMessages[i]
                spamMessages.append(message)
            }
        }
        
        return spamMessages
    }
    
    private func retrieveUnreadEmails(withSession session: MCOIMAPSession, withCompletion completion: @escaping ([MCOIMAPMessage])->Void) {
        let requestKind: MCOIMAPMessagesRequestKind = [.flags, .fullHeaders, .structure]
        let uids = MCOIndexSet(range: MCORange(location: 1, length: .max))
        let fetchOperation = session.fetchMessagesOperation(withFolder: "INBOX", requestKind: requestKind, uids: uids)
        
        fetchOperation?.start { error, messages, indexSet in
            guard error == nil, let messages = messages else { completion([]); print(error?.localizedDescription ?? ""); return }
            let unread = messages
            completion(unread)
        }
    }
}

private extension MCOIMAPMessage {
    var spamClassifierInput: EmailSpamClassifierInput {
        return EmailSpamClassifierInput(text: header.subject ?? "Empty Subject" )
    }
}
