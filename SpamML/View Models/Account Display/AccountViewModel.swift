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
}
