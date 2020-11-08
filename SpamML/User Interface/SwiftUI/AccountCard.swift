//
//  AccountCard.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/8/20.
//

import SwiftUI

struct AccountCard: View {
    @ObservedObject var accountViewModel: AccountViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(uiImage: accountViewModel.provider.icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35, alignment: .center)
                    .foregroundColor(.white)
                Text(accountViewModel.emailAddress)
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .bold, design: .default))
                Spacer()
                Text("\(accountViewModel.flaggedEmails.count)")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(accountViewModel.provider.tintColor))
                    .frame(height: 20, alignment: .center)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding([.horizontal, .top])
            
            Divider()
                .background(Color.white)
            
            
            
            Spacer()
        }
        .frame(width: 375, height: 500, alignment: .center)
        .background(Color(accountViewModel.provider.tintColor))
        .cornerRadius(30, antialiased: true)
        .shadow(color: Color(accountViewModel.provider.tintColor.withAlphaComponent(0.75)), radius: 10, x: 0, y: 5)
    }
}

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        let accountViewModel = AccountViewModel(withIMAPCredentials: IMAPCredentials(username: "ctdewaters@icloud.com", password: "Password", port: 993, hostname: "imap.mail.me.com"))
        AccountCard(accountViewModel: accountViewModel)
    }
}
