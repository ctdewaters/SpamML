//
//  MLFilterController.swift
//  SpamML
//
//  Created by Collin DeWaters on 12/12/20.
//

import CoreML
import MailCore

/// Provides an interface to filter spam messages in multiple data types using `EmailSpamClassifier`.
class MLFilterController {
    let emailSpamClassifier: EmailSpamClassifier = {
        try! EmailSpamClassifier(configuration: MLModelConfiguration())
    }()

    // MARK: - Initialization
    init() {}
    
    // MARK: - Filtering
    
    /// Runs a simple filter on IMAP messages from MailCore.
    /// This function will only test the `subject` field of the header.
    /// Use the returned properties of this function to run a full test for validity.
    /// - Parameter imapMessages: The IMAP messages from a MailCore fetch operation.
    /// - Returns: The filtered IMAP messages, which triggered the spam filter.
    func quickFilter(imapMessages: [MCOIMAPMessage]) -> [MCOIMAPMessage] {
        var spamMessages = [MCOIMAPMessage]()
        for message in imapMessages {
            let input = message.spamClassifierInput
            
            let output = try? emailSpamClassifier.prediction(input: input)
            
            guard output?.label == "spam" else { continue }
            spamMessages.append(message)
        }
        
        return spamMessages
    }
    
    /// Runs a complete filter on generic email messages.
    /// Use this function only on a collection of `Email` instances after running the respective `quickFilter` function for the source.
    /// - Parameter emailMessages: The email messages.
    /// - Returns: The filtered email messages which triggered the spam filter.
    func filter(emailMessages: [Email]) -> [Email] {
        var spamMessages = [Email]()
        
        for message in emailMessages {
            let subjectOutput = try? emailSpamClassifier.prediction(text: message.subject)
            let bodyOutput = try? emailSpamClassifier.prediction(text: message.body)
            
            let subjectIsSpam = subjectOutput?.isSpam ?? false
            let bodyIsSpam = bodyOutput?.isSpam ?? false
            
            guard subjectIsSpam, bodyIsSpam else { continue }
            spamMessages.append(message)
        }
        
        return spamMessages
    }
}

private extension EmailSpamClassifierOutput {
    var isSpam: Bool { label == "spam" }
}

private extension MCOIMAPMessage {
    /// For `MCOIMAPMessage` filtering, we only want to do a preliminary test of the subject.
    /// For body filtering, create an instance of `Email` using the `email` calculated property in `MCOIMAPMessage`.
    var spamClassifierInput: EmailSpamClassifierInput { EmailSpamClassifierInput(text: header.subject) }
}
