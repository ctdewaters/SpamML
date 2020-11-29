//
//  AccountViewModel.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/8/20.
//

import GTMAppAuth
import SwiftUI

class AccountViewModel: ObservableObject, Identifiable {
    let emailAddress: String
    let provider: Provider
    
    var id: String = UUID().uuidString
    
    @Published var flaggedEmails = [EmailViewModel]()
    
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
        emailAddress = googleAuthentication.userInfo?.email ?? "Invalid authorization"
        provider = .google
    }
    
    init(withIMAPCredentials imapCredentials: IMAPCredentials) {
        emailAddress = imapCredentials.username
        
        if imapCredentials.hostname == "imap.mail.me.com" {
            provider = .icloud
        }
        else {
            provider = .imap
        }
     }

    // MARK: - Test View Models
    // Test emails for the preview
    private static let emailViewModel1 = EmailViewModel(subject: "Buy the new iPhone 12 Pro Max!", bodyPreview: "Available now, starting at $1099! Order yours today before it's too late! This offer will only last for a short period of time!", body: nil, timestamp: Date())
    private static let emailViewModel2 = EmailViewModel(subject: "Hello hi!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
    private static let emailViewModel3 = EmailViewModel(subject: "Hello sadf!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
    private static let emailViewModel4 = EmailViewModel(subject: "Hello asddas!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
    private static let emailViewModel5 = EmailViewModel(subject: "Hello adasdvasdvads!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
    private static let emailViewModel6 = EmailViewModel(subject: "Hello asvdwavs!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
    private static let emailViewModel7 = EmailViewModel(subject: "Hello avsdvasdv!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())

    static var test_iCloud: AccountViewModel {
        let accountViewModel = AccountViewModel(withIMAPCredentials: IMAPCredentials(username: "ctdewaters@icloud.com", password: "Password", port: 993, hostname: "imap.mail.me.com"))
        accountViewModel.flaggedEmails = [emailViewModel1, emailViewModel2, emailViewModel3, emailViewModel4, emailViewModel5, emailViewModel6, emailViewModel7]
        return accountViewModel
    }
    
    static var test_imap: AccountViewModel {
        let accountViewModel = AccountViewModel(withIMAPCredentials: IMAPCredentials(username: "ctdewaters@collindewaters.com", password: "Password", port: 993, hostname: "imap.collindewaters.com"))
        accountViewModel.flaggedEmails = [emailViewModel1, emailViewModel2, emailViewModel3, emailViewModel4, emailViewModel5, emailViewModel6, emailViewModel7]
        return accountViewModel
    }
}
