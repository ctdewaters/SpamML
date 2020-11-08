//
//  IMAPAccountViewModel.swift
//  SpamML
//
//  Created by Collin DeWaters on 10/26/20.
//

import Combine
import SwiftUI
import MailCore

class IMAPAccountViewModel: ObservableObject {
    @Published var username = String()
    @Published var password = String()
    @Published var hostname = String()
    @Published var port = String()
    
    @Published var isAuthenticating = false
    
    var onAuthenticatedAccount = {}
    
    /// Runs a sample IMAP operation to test validity of the credentials
    /// - Parameter completion: A callback run when the operation completes. This is supplied with `true` if the request was successful.
    func authenticate(withCompletion completion: @escaping (Bool)->Void) {
        isAuthenticating = true
        
        let imapCredentials = IMAPCredentials(username: username, password: password, port: UInt32(port) ?? 993, hostname: hostname)
        let imapSession = imapCredentials.createMailCoreSession()
        let fetchFoldersOp = imapSession.fetchAllFoldersOperation()
        
        fetchFoldersOp?.start { [weak self] error, _ in
            self?.isAuthenticating = false
            
            let successful = error == nil
            
            DispatchQueue.main.async { completion(successful) }
            
            // Save to keychain if successful.
            if successful {
                Keychain.shared.save(imapCredentials: imapCredentials, forKey: imapCredentials.username)
                self?.onAuthenticatedAccount()
            }
        }
    }
}
