//
//  GoogleSignInController.swift
//  SpamML
//
//  Created by Collin DeWaters on 10/24/20.
//

import GTMAppAuth
import AppAuth
import MailCore
import Reachability

/// Handles interaction with the Google Sign In API.
final class GoogleSignInController: NSObject {
    var currentAuthorizationFlow: OIDExternalUserAgentSession!
    var authorization: GTMAppAuthFetcherAuthorization!
    
    static var shared: GoogleSignInController!
    
    private let redirectURI = "com.googleusercontent.apps.906281823650-n37hvdg2sskj88bd64sslh04r08c9ieo"
    private let clientID = "906281823650-n37hvdg2sskj88bd64sslh04r08c9ieo.apps.googleusercontent.com"
    private let issuer = "https://accounts.google.com"
    
    private let reachability: Reachability = { try! Reachability() }()
    
    private let authKey = "googleauthkey_changethis"
    
    override init() {
    }
    
    func performLoginIfRequired(withPresentingViewController presentingViewController: UIViewController, andCompletion completion: @escaping ()->Void) {
        if reachability.connection != .unavailable {
            DispatchQueue.main.async {
                self.checkIfAuthorizationIsValid { authenticated in
                    assert(Thread.current.isMainThread, "ERROR MAIN THREAD REQUIRED")
                    
                    if authenticated {
                        completion()
                    }
                    else {
                        self.performInitialAuthorization(withPresentingViewController: presentingViewController, andCompletion: completion)
                    }
                }
            }
        }
    }
    
    private func saveState() {
        if authorization.canAuthorize() {
            GTMAppAuthFetcherAuthorization.save(authorization, toKeychainForName: authKey)
        }
        else {
            print("GoogleSignInController: WARNING, attempt to save a Google authorization which is unable to be authorized. Discarding.")
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: authKey)
        }
    }
    
    private func loadState() {
        guard let auth = GTMAppAuthFetcherAuthorization(fromKeychainForName: authKey) else { return }
        
        if auth.canAuthorize() {
            self.authorization = auth
        }
        else {
            print("GoogleSignInController: WARNING, loaded Google authorization unable to be authorized. Discaring.")
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: authKey)
        }
    }
    
    private func performInitialAuthorization(withPresentingViewController presentingViewController: UIViewController, andCompletion completion: @escaping ()->Void) {
        let issuerURL = URL(string: issuer)!
        let redirectURL = URL(string: redirectURI)!
        
        print("GoogleSignInController: Fetching configuration for issuer: \(issuer).")
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuerURL) { [weak self] (config, error) in
            guard let sself = self else { return }
            guard let config = config else {
                print("GoogleSignInController: Error retrieving discovery document: \(error?.localizedDescription ?? "")")
                self?.authorization = nil
                return
            }
            
            print("GoogleSignInController: Discovered configuration: \(config)")
            
            let request = OIDAuthorizationRequest(configuration: config,
                                                  clientId: sself.clientID,
                                                  scopes: [OIDScopeOpenID, OIDScopeProfile, "https://mail.google.com/"],
                                                  redirectURL: redirectURL,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            
            print("GoogleSignInController: Initiating authorization request with scope: \(request.scope ?? "")")
            
            sself.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { [weak self] authState, error in
                if let authState = authState {
                    self?.authorization = GTMAppAuthFetcherAuthorization(authState: authState)
                    print("GoogleSignInController: Retrieved authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "")")
                    self?.saveState()
                }
                else {
                    self?.authorization = nil
                    print("GoogleSignInController: Authorization error: \(error?.localizedDescription ?? "")")
                }
                DispatchQueue.main.async { completion() }
            }
        }
    }

    private func checkIfAuthorizationIsValid(withCompletion completion: ((Bool)->Void)?) {
        print("GoogleSignInController: Performing UserInfo request.")
        
        // Creates a GTMSessionFetcherService with the authorization.
        // Normally you would save this service object and re-use it for all REST API calls.
        let fetcherService = GTMSessionFetcherService()
        fetcherService.authorizer = authorization
        
        // Creates a fetcher for the API call.
        let fetcher = fetcherService.fetcher(withURLString: "https://www.googleapis.com/oauth2/v3/userinfo")
        fetcher.beginFetch { [unowned self] data, error in
            guard error == nil else {
                // OIDOAuthTokenErrorDomain indicates an issue with the authorization.
                let error = error! as NSError
                if error.domain == OIDOAuthTokenErrorDomain {
                    GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: self.authKey)
                    self.authorization = nil
                    
                    print("GoogleSignInController: Authorization error during token refresh. Cleared authentication state. \(error)")
                    completion?(false)
                }
                else {
                    print("GoogleSignInController: Transient error during token refresh. \(error)")
                    completion?(false)
                }
                return
            }
            
            print("GoogleSignInController: Authentication is valid.")
            completion?(true)
        }
    }
}
