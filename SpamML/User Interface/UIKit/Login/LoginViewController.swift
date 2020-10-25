//
//  LoginViewController.swift
//  SpamML
//
//  Created by Collin DeWaters on 10/24/20.
//

import UIKit
import SwiftUI

/// Handles adding an email account to the application.
class LoginViewController: UIViewController {
    @IBOutlet private weak var googleButton: UIButton!
    
    init() {
        super.init(nibName: "LoginViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signInWithGoogle(_ sender: Any) {
        GoogleSignInController.shared.performLoginIfRequired(withPresentingViewController: self) {
            
        }
    }
    
}

struct LoginView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LoginViewController {
        LoginViewController()
    }
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {}
}
