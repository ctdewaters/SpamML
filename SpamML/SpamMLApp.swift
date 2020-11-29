//
//  SpamMLApp.swift
//  Shared
//
//  Created by Collin DeWaters on 10/23/20.
//

import SwiftUI

@main
struct SpamMLApp: App {
    init() {
        GoogleSignInService.shared = GoogleSignInService()
        
        UIPageControl.appearance().pageIndicatorTintColor = .tertiaryLabel
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().backgroundStyle = .automatic
    }

    var body: some Scene {
        WindowGroup {
            if Keychain.shared.accountKeys.isEmpty {
                LoginView()
            }
            else {
                ContentView(accountViewModels: Keychain.shared.accountKeys.accountViewModels)
            }
        }
    }
}
