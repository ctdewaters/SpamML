//
//  ContentView.swift
//  Shared
//
//  Created by Collin DeWaters on 10/23/20.
//

import SwiftUI

struct ContentView: View {
    let keys = Keychain.shared.accountKeys
    
    var body: some View {
        VStack {
            ForEach(keys) { key in
                HStack {
                    Text(key.keyString)
                    Text("\(key.sourceRaw)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
