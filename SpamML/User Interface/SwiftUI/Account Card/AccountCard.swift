//
//  AccountCard.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/8/20.
//

import SwiftUI

/// Displays account information and spam emails for an authenticated account.
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
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .lineLimit(1)
                        .foregroundColor(.white)
                    Spacer()
                    
                    Text("\(accountViewModel.flaggedEmails.count)")
                        .lineLimit(1)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.trailing, 16)
                }
                .padding([.horizontal, .top])

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
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 60, trailing: 0))
                }
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.05),
                    .init(color: .black, location: 0.8),
                    .init(color: .clear, location: 1)
                ]), startPoint: .top, endPoint: .bottom))
            }
            
            // Delete emails button
            Button(action: {}, label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete All Spam")
                }
            })
            .font(.headline)
            .foregroundColor(.red)
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(Color.white)
            .cornerRadius(50)

        }
        .padding(.bottom, 16)
        .frame(width: 375, height: 500, alignment: .topLeading)
        .background(
            Image(uiImage: accountViewModel.provider.cardBackground)
                .resizable()
                .overlay(Color(UIColor.black.withAlphaComponent(0.07)))
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color(UIColor.darkGray.withAlphaComponent(0.45)), radius: 10, x: 0, y: 5)
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

extension View {
    // view.inverseMask(_:)
    public func inverseMask<M: View>(_ mask: M) -> some View {
        // exchange foreground and background
        let inversed = mask
            .foregroundColor(.black)  // hide foreground
            .background(Color.white)  // let the background stand out
            .compositingGroup()       // ⭐️ composite all layers
            .luminanceToAlpha()       // ⭐️ turn luminance into alpha (opacity)
        return self.mask(inversed)
    }
}
