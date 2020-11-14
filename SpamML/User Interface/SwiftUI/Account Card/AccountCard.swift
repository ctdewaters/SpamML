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
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            VStack(alignment: .center, spacing: 0) {
                // Header
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
                .padding()
                Divider()
                    .background(Color.white)
                
                // Filtered Emails
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(accountViewModel.flaggedEmails, id: \.self) { email in
                            EmailRow(emailViewModel: email)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            Divider()
                                .background(Color(UIColor.white.withAlphaComponent(0.8)))
                                .padding(.leading, 16)
                        }
                    }
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 60, trailing: 0))
                }
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.75),
                    .init(color: .clear, location: 1)
                ]), startPoint: .top, endPoint: .bottom))
            }
            
            Text("Delete All Spam")
                .font(.headline)
                .foregroundColor(Color(accountViewModel.provider.tintColor))
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .background(Color.white)
                .cornerRadius(50)
        }
        .padding(.bottom, 16)
        .frame(width: 375, height: 500, alignment: .topLeading)
        .background(Color(accountViewModel.provider.tintColor))
        .cornerRadius(30, antialiased: true)
        .shadow(color: Color(accountViewModel.provider.tintColor.withAlphaComponent(0.75)), radius: 10, x: 0, y: 5)
    }
}

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        
        // Test emails for the preview
        let emailViewModel1 = EmailViewModel(subject: "Buy the new iPhone 12 Pro Max!", bodyPreview: "Available now, starting at $1099! Order yours today before it's too late! This offer will only last for a short period of time!", body: nil, timestamp: Date())
        let emailViewModel2 = EmailViewModel(subject: "Hello hi!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
        let emailViewModel3 = EmailViewModel(subject: "Hello sadf!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
        let emailViewModel4 = EmailViewModel(subject: "Hello asddas!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
        let emailViewModel5 = EmailViewModel(subject: "Hello adasdvasdvads!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
        let emailViewModel6 = EmailViewModel(subject: "Hello asvdwavs!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())
        let emailViewModel7 = EmailViewModel(subject: "Hello avsdvasdv!", bodyPreview: "This is a test Email. Do not click on it!", body: nil, timestamp: Date())


        let accountViewModel = AccountViewModel(withIMAPCredentials: IMAPCredentials(username: "ctdewaters@icloud.com", password: "Password", port: 993, hostname: "imap.mail.me.com"))
        
        accountViewModel.flaggedEmails = [emailViewModel1, emailViewModel2, emailViewModel3, emailViewModel4, emailViewModel5, emailViewModel6, emailViewModel7]
        
        return AccountCard(accountViewModel: accountViewModel)
    }
}
