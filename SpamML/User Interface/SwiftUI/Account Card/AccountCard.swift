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
                        .frame(width: 25, height: 25, alignment: .center)
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
                }
                .padding([.horizontal, .top])

                if accountViewModel.isRefreshingEmails {
                    // Progress View
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                }
                else {
                    // Filtered Emails
                    ScrollView {
                        LazyVStack {
                            ForEach(accountViewModel.flaggedEmails) { email in
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
            }
            
            if !accountViewModel.isRefreshingEmails {
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
        .onAppear {
            accountViewModel.updateFilteredEmails()
        }
    }
}

struct AccountCard_Previews: PreviewProvider {
    static var previews: some View {
        AccountCard(accountViewModel: .test_iCloud)
    }
}
