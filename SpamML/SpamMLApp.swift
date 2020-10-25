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
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
