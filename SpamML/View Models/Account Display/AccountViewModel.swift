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
        imapController?.retrieveIMAPFolderInfo { folderInfo in
            print(folderInfo?.uidNext ?? -1)
            print(folderInfo?.uidValidity ?? -1)
            print(folderInfo?.firstUnseenUid ?? -1)
        }
    }

    // MARK: - Test View Models
    // Test emails for the preview
    private static let email1 = Email(subject: "Buy the new iPhone 12 Pro Max!", body: "Available now, starting at $1099! Order yours today before it's too late! This offer will only last for a short period of time!", timestamp: Date())
    private static let email2 = Email(subject: "Hello hi!", body: "This is a test Email. Do not click on it!", timestamp: Date())
    private static let email3 = Email(subject: "Hello sadf!", body: "This is a test Email. Do not click on it!", timestamp: Date())
    private static let email4 = Email(subject: "Hello asddas!", body: "This is a test Email. Do not click on it!", timestamp: Date())
    private static let email5 = Email(subject: "Hello adasdvasdvads!", body: "This is a test Email. Do not click on it!", timestamp: Date())
    private static let email6 = Email(subject: "Hello asvdwavs!", body: "This is a test Email. Do not click on it!", timestamp: Date())
    private static let email7 = Email(subject: "Hello avsdvasdv!", body: "This is a test Email. Do not click on it!", timestamp: Date())

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
