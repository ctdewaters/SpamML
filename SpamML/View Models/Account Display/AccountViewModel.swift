//
//  AccountViewModel.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/8/20.
//

import MailCore
import GTMAppAuth
import SwiftUI

/// A view model displayed in an `AccountCard` instance.
class AccountViewModel: ObservableObject, Identifiable {
    let emailAddress: String
    let provider: Provider
    
    var id: String = UUID().uuidString
    
    private(set) var imapCredentials: IMAPCredentials?
    private(set) var googleAuth: GTMAppAuthFetcherAuthorization?
    
    @Published var flaggedEmails = [Email]() {
        didSet {
            isRefreshingEmails = false
        }
    }
    
    @Published var isRefreshingEmails = false
    
    private lazy var imapController: IMAPController? = {
        guard let imapCredentials = imapCredentials else { return nil }
        return IMAPController(withIMAPCredentials: imapCredentials)
    }()
    
    private lazy var filterController: MLFilterController = { MLFilterController() }()
    
    enum Provider {
        case google, imap, icloud
        
        var tintColor: UIColor {
            switch self {
            case .google : return .systemGreen
            case .imap   : return .systemOrange
            case .icloud : return .systemBlue
            }
        }
        
        var icon: UIImage {
            switch self {
            case .google : return UIImage(systemName: "envelope.fill")!
            case .imap   : return UIImage(systemName: "mail.stack.fill")!
            case .icloud : return UIImage(systemName: "icloud.circle.fill")!
            }
        }
        
        var cardBackground: UIImage {
            switch self {
            case .google : return UIImage(named: "googleCardBackground")!
            case .imap   : return UIImage(named: "imapCardBackground")!
            case .icloud : return UIImage(named: "icloudCardBackground")!
            }
        }
    }
    
    static func fromAccountKey(accountKey: AccountKey) -> AccountViewModel? {
        if let googleAuth = accountKey.googleAuthentication { return AccountViewModel(withGoogleAuthentication: googleAuth) }
        if let imapCredentials = accountKey.imapCredentials { return AccountViewModel(withIMAPCredentials: imapCredentials) }
        
        return nil
    }
    
    init(withGoogleAuthentication googleAuthentication: GTMAppAuthFetcherAuthorization) {
        googleAuth = googleAuthentication
        emailAddress = googleAuthentication.userInfo?.email ?? "Invalid authorization"
        provider = .google
    }
    
    init(withIMAPCredentials imapCredentials: IMAPCredentials) {
        self.imapCredentials = imapCredentials
        emailAddress = imapCredentials.username
        
        if imapCredentials.hostname == "imap.mail.me.com" {
            provider = .icloud
        }
        else {
            provider = .imap
        }
    }
    
    // MARK: - Filtering
    func filterLatestUnread() {
        guard provider == .icloud else { return }

        isRefreshingEmails = true
        
        imapController?.retrieveIMAPFolderInfo { [weak self] folderInfo in
            guard let firstUnseenUID = folderInfo?.firstUnseenUid,
                  firstUnseenUID > 0,
                  let messageCount = folderInfo?.messageCount else { self?.isRefreshingEmails = false; return }
            
            let length = UInt64(messageCount) - UInt64(firstUnseenUID)
            let range = MCORange(location: UInt64(firstUnseenUID), length: length)
                                    
            self?.imapController?.retrieveMessages(inUIDRange: range) { [weak self] messages in
                
                //Filter the messages.
                let quickFilterSpamMessages = self?.filterController.quickFilter(imapMessages: messages) ?? []
                            
                // Render the full messages for the spam
                self?.imapController?.renderEmailModels(forMessages: quickFilterSpamMessages) { [weak self] emails in
                    // Run a complete filter on each triggered message.
                    let spamEmails = self?.filterController.filter(emailMessages: emails) ?? []
                    
                    self?.isRefreshingEmails = false
                    self?.flaggedEmails = spamEmails
                    
                }
            }
        }
    }

    // MARK: - Test View Models
    // Test emails for the preview
    private static let email1 = Email.testInstance(subject: "Buy the new iPhone 12 Pro Max!", body: "Available now, starting at $1099! Order yours today before it's too late! This offer will only last for a short period of time!", id: "1")
    private static let email2 = Email.testInstance(subject: "Hello hi!", body: "This is a test Email. Do not click on it!", id: "2")
    private static let email3 = Email.testInstance(subject: "Hello sadf!", body: "This is a test Email. Do not click on it!", id: "3")
    private static let email4 = Email.testInstance(subject: "Hello asddas!", body: "This is a test Email. Do not click on it!", id: "4")
    private static let email5 = Email.testInstance(subject: "Hello adasdvasdvads!", body: "This is a test Email. Do not click on it!", id: "5")
    private static let email6 = Email.testInstance(subject: "Hello asvdwavs!", body: "This is a test Email. Do not click on it!", id: "6")
    private static let email7 = Email.testInstance(subject: "Hello avsdvasdv!", body: "This is a test Email. Do not click on it!", id: "7")

    static var test_iCloud: AccountViewModel {
        let accountViewModel = AccountViewModel(withIMAPCredentials: IMAPCredentials(username: "ctdewaters@icloud.com", password: "Password", port: 993, hostname: "imap.mail.me.com"))
        accountViewModel.flaggedEmails = [email1, email2, email3, email4, email5, email6, email7]
        return accountViewModel
    }
    
    static var test_imap: AccountViewModel {
        let accountViewModel = AccountViewModel(withIMAPCredentials: IMAPCredentials(username: "ctdewaters@collindewaters.com", password: "Password", port: 993, hostname: "imap.collindewaters.com"))
        accountViewModel.flaggedEmails = [email1, email2, email3, email4, email5, email6, email7]
        return accountViewModel
    }
}
