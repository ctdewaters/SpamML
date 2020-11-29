//
//  ContentView.swift
//  Shared
//
//  Created by Collin DeWaters on 10/23/20.
//

import SwiftUI

struct ContentView: View {
    @State var accountViewModels = [AccountViewModel]()
    @State var currentPage = 0
    @State var showingAddAccountModal = false
    
    var body: some View {
        NavigationView {
            VStack {
                PageView(accountViewModels: accountViewModels)
                Spacer()
            }
            .navigationBarTitle("SpamML")
            .navigationBarItems(trailing:
                Button("Add Account") { self.showingAddAccountModal = true }
            )
        }
        .sheet(isPresented: $showingAddAccountModal, content: {
            LoginView()
        })
    }
}

private struct PageView: View {
    let accountViewModels: [AccountViewModel]
    
    var body: some View {
        TabView {
            ForEach(accountViewModels) { account in
                AccountCard(accountViewModel: account)
                    .frame(height: 500)
            }
        }
        .onAppear {
            UIScrollView.appearance().alwaysBounceVertical = false
        }
        .frame(width: UIScreen.main.bounds.width, height: 625)
        .tabViewStyle(PageTabViewStyle())
        .accentColor(.blue)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(accountViewModels: [.test_iCloud, .test_imap])
    }
}
