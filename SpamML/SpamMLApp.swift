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
        GoogleSignInController.shared = GoogleSignInController()
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
                .onOpenURL{ url in
                    //GoogleSignInController.shared.handle(url: url)
                }
        }
    }
}
