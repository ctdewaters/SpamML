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
        
    private(set) lazy var session: MCOIMAPSession? = {
        self.credentials.createMailCoreSession()
    }()
    
    // MARK: - Typealiases
    typealias FolderInfoFetchCompletion = (MCOIMAPFolderInfo?) -> Void
    typealias MessageFetchCompletion = ([MCOIMAPMessage]) -> Void
    typealias PlainTextBodyCompletion = (String) -> Void
    typealias EmailModelRenderingCompletion = (Email) -> Void
    typealias EmailModelsRenderingCompletion = ([Email]) -> Void
    
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
    func retrieveMessages(folder: String = "INBOX", requestKind: MCOIMAPMessagesRequestKind = [.fullHeaders, .flags, .structure], inUIDRange range: MCORange, withCompletion completion: @escaping MessageFetchCompletion) {
        dispatchQueue.async { [weak self] in
            let uids = MCOIndexSet(range: range)
            
            guard let fetchOperation = self?.session?.fetchMessagesByNumberOperation(withFolder: folder, requestKind: requestKind, numbers: uids) else { completion([]); return }
            
            // Fetch the messages in the UID set.
            fetchOperation.start { error, messages, _ in
                guard error == nil, let messages = messages else { completion([]); return }
                completion(messages)
            }
        }
    }
    
    // MARK: - Email Rendering
    func renderEmailModels(forMessages messages: [MCOIMAPMessage], inFolder folder: String = "INBOX", withCompletion completion: @escaping EmailModelsRenderingCompletion) {
        guard messages.count > 0 else { completion([]); return }
        
        var emails = [Email]()
        
        func runCompletionIfNeeded() {
            guard emails.count == messages.count else { return }
            
            // Sort emails by UID
            emails = emails.sorted { $0.uid > $1.uid }
            
            completion(emails)
        }
        
        // Render each of the messages to an `Email` model
        messages.forEach { [weak self] message in
            self?.renderEmailModel(withMessage: message) { email in
                emails.append(email)
                runCompletionIfNeeded()
            }
        }
    }
    
    private func renderEmailModel(withMessage message: MCOIMAPMessage, inFolder folder: String = "INBOX", withCompletion completion: @escaping EmailModelRenderingCompletion) {
        renderPlainTextBody(forMessage: message, inFolder: folder) { body in
            
            // Create `Contact` instances
            let from = message.header.from.contact
            let to = message.header.toAddresses.map { $0.contact }
            let cc = message.header.ccAddresses.map { $0.contact }
            let bcc = message.header.bccAddresses.map { $0.contact }
            
            let email = Email(subject: message.header.subject, body: body, timestamp: message.header.date, id: "\(message.uid)", from: from, to: to, cc: cc, bcc: bcc)
            completion(email)
        }
    }
    
    private func renderPlainTextBody(forMessage message: MCOIMAPMessage, inFolder folder: String = "INBOX", withCompletion completion: @escaping PlainTextBodyCompletion) {
        dispatchQueue.async { [weak self] in
            
            guard let renderingOperation = self?.session?.plainTextBodyRenderingOperation(with: message, folder: folder) else { completion(""); return }
            
            renderingOperation.start { plainTextBody, error in
                guard error == nil, let body = plainTextBody else { completion(""); return }
                completion(body)
            }
        }
    }
    
    // MARK: - CoreML Filtering
}

private extension MCOMessageHeader {
    var toAddresses:  [MCOAddress] { to as? [MCOAddress] ?? [] }
    var ccAddresses:  [MCOAddress] { cc as? [MCOAddress] ?? [] }
    var bccAddresses: [MCOAddress] { cc as? [MCOAddress] ?? [] }
}
