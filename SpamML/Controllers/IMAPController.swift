//
//  IMAPController.swift
//  SpamML
//
//  Created by Collin DeWaters on 12/12/20.
//

import MailCore
import CoreML

/// Provides retrieval of IMAP messages through MailiCore.
class IMAPController {
    let credentials: IMAPCredentials
    
    let filterController: MLFilterController = { MLFilterController() }()
    
    private(set) lazy var session: MCOIMAPSession? = {
        self.credentials.createMailCoreSession()
    }()
    
    // MARK: - Typealiases
    typealias FolderInfoFetchCompletion = (MCOIMAPFolderInfo?) -> Void
    typealias MessageFetchCompletion = ([MCOIMAPMessage]) -> Void
    typealias PlainTextBodyCompletion = (String) -> Void
    typealias EmailModelRenderingCompletion = (Email) -> Void
    
    private let dispatchQueue = DispatchQueue(label: "IMAPController", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    // MARK: - Initialization
    init(withIMAPCredentials creds: IMAPCredentials) {
        self.credentials = creds
    }
    
    // MARK: - Retrieving Folder Info
    func retrieveIMAPFolderInfo(withFolderName folderName: String = "INBOX", completion: @escaping FolderInfoFetchCompletion) {
        dispatchQueue.async { [weak self] in
            guard let folderInfoOperation = self?.session?.folderInfoOperation(folderName) else { completion(nil); return }
            
            folderInfoOperation.start { error, folderInfo in
                completion(folderInfo)
            }
        }
    }
    
    // MARK: - General Retrieval
    func retrieveMessageHeaders(folder: String = "INBOX", inUIDRange range: MCORange, withCompletion completion: @escaping MessageFetchCompletion) {
        retrieveMessages(folder: folder, requestKind: [.fullHeaders, .flags], inUIDRange: range, withCompletion: completion)
    }
    
    func retrieveMessages(folder: String = "INBOX", requestKind: MCOIMAPMessagesRequestKind, inUIDRange range: MCORange, withCompletion completion: @escaping MessageFetchCompletion) {
        dispatchQueue.async { [weak self] in
            let uids = MCOIndexSet(range: range)
            guard let fetchOperation = self?.session?.fetchMessagesOperation(withFolder: "INBOX", requestKind: requestKind, uids: uids) else { completion([]); return }
            
            // Fetch the messages in the UID set.
            fetchOperation.start { error, messages, _ in
                guard error == nil, let messages = messages else { completion([]); return }
                completion(messages)
            }
        }
    }
    
    // MARK: - Email Rendering
    private func renderEmailModel(withMessage message: MCOIMAPMessage, inFolder folder: String = "INBOX", withCompletion completion: @escaping EmailModelRenderingCompletion) {
        renderPlainTextBody(forMessage: message, inFolder: folder) { body in
            let email = Email(subject: message.header.subject, body: body, timestamp: message.header.date)
            completion(email)
        }
    }
    
    private func renderPlainTextBody(forMessage message: MCOIMAPMessage, inFolder folder: String = "INBOX", withCompletion completion: @escaping PlainTextBodyCompletion) {
        dispatchQueue.async { [weak self] in
            guard let renderingOperation = self?.session?.plainTextBodyRenderingOperation(with: message, folder: folder, stripWhitespace: true) else { completion(""); return }
            
            renderingOperation.start { plainTextBody, error in
                guard error == nil, let body = plainTextBody else { completion(""); return }
                completion(body)
            }
        }
    }
    
    // MARK: - CoreML Filtering
}
