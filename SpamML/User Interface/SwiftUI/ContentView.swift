//
//  ContentView.swift
//  Shared
//
//  Created by Collin DeWaters on 10/23/20.
//

import SwiftUI

struct ContentView: View {
    var keys: [AccountKey] { Keychain.shared.accountKeys }
    
    @State private var accountViewModels = [AccountViewModel]()
    
    var body: some View {
        VStack {
            ForEach(accountViewModels) { accountViewModel in
                HStack {
                    Text(accountViewModel.emailAddress)
                    Text("\(accountViewModel.id)")
                }
            }
        }
        .onAppear { self.accountViewModels = keys.accountViewModels }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
