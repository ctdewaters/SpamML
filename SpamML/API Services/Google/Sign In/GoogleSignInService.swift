//
//  GoogleSignInService.swift
//  SpamML
//
//  Created by Collin DeWaters on 10/24/20.
//

import GTMAppAuth
import AppAuth
import MailCore
import Reachability

/// Handles interaction with the Google Sign In API.
final class GoogleSignInService: NSObject {
    static var shared: GoogleSignInService!

    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    var authorization: GTMAppAuthFetcherAuthorization?
        
    private let redirectURI = "com.googleusercontent.apps.906281823650-r09686rj7oonfrh65lbcke4opah72ojs:/oauthredirect"
    private let clientID = "906281823650-r09686rj7oonfrh65lbcke4opah72ojs.apps.googleusercontent.com"
    private let issuer = "https://accounts.google.com"
    private let authKey = "googleauthkey_changethis"
    
    private let reachability: Reachability = { try! Reachability() }()
    
    private let fetcherService = GTMSessionFetcherService()
    
    
    override init() {
    }
    
    func performLoginIfRequired(withPresentingViewController presentingViewController: UIViewController, andCompletion completion: @escaping ()->Void) {
        if reachability.connection != .unavailable {
            DispatchQueue.main.async {
                self.checkIfAuthorizationIsValid(self.authorization) { authenticated in
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
        if let auth = authorization, auth.canAuthorize() {
            GTMAppAuthFetcherAuthorization.save(auth, toKeychainForName: authKey)
        }
        else {
            print("GoogleSignInService: WARNING, attempt to save a Google authorization which is unable to be authorized. Discarding.")
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: authKey)
        }
    }
    
    private func loadState() {
        guard let auth = GTMAppAuthFetcherAuthorization(fromKeychainForName: authKey) else { return }
        
        if auth.canAuthorize() {
            self.authorization = auth
        }
        else {
            print("GoogleSignInService: WARNING, loaded Google authorization unable to be authorized. Discaring.")
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: authKey)
        }
    }
    
    private func performInitialAuthorization(withPresentingViewController presentingViewController: UIViewController, andCompletion completion: @escaping ()->Void) {
        let issuerURL = URL(string: issuer)!
        let redirectURL = URL(string: redirectURI)!
        
        print("GoogleSignInService: Fetching configuration for issuer: \(issuer).")
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuerURL) { [weak self] (config, error) in
            guard let sself = self else { return }
            guard let config = config else {
                print("GoogleSignInService: Error retrieving discovery document: \(error?.localizedDescription ?? "")")
                self?.authorization = nil
                return
            }
            
            print("GoogleSignInService: Discovered configuration: \(config)")
            
            let request = OIDAuthorizationRequest(configuration: config,
                                                  clientId: sself.clientID,
                                                  scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail, "https://mail.google.com/"],
                                                  redirectURL: redirectURL,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
            
            print("GoogleSignInService: Initiating authorization request with scope: \(request.scope ?? "")")
            
            sself.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { [weak self] authState, error in
                if let authState = authState {
                    self?.authorization = GTMAppAuthFetcherAuthorization(authState: authState)
                    print("GoogleSignInService: Retrieved authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "")")
                    self?.saveState()
                }
                else {
                    self?.authorization = nil
                    print("GoogleSignInService: Authorization error: \(error?.localizedDescription ?? "")")
                }
                DispatchQueue.main.async { completion() }
            }
        }
    }

    private func checkIfAuthorizationIsValid(_ authorization: GTMAppAuthFetcherAuthorization?, withCompletion completion: ((Bool)->Void)?) {
        retrieveUserInfo(withAuthorization: authorization) { _, error in
            guard error == nil else {
                // OIDOAuthTokenErrorDomain indicates an issue with the authorization.
                let error = error! as NSError
                if error.domain == OIDOAuthTokenErrorDomain {
                    GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: self.authKey)
                    self.authorization = nil
                    
                    completion?(false)
                }
                else {
                    completion?(false)
                }
                return
            }
            completion?(true)
        }
    }
}

// MARK: - UserInfo
extension GoogleSignInService {
    func retrieveUserInfo(withAuthorization authorization: GTMAppAuthFetcherAuthorization?, withCompletion completion: @escaping (GoogleUserInfo?, Error?)->Void) {
        
        fetcherService.authorizer = authorization
                
        let fetcher = fetcherService.fetcher(withURLString: "https://www.googleapis.com/oauth2/v3/userinfo")
        fetcher.beginFetch { data, error in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let userInfo = try? JSONDecoder().decode(GoogleUserInfo.self, from: data)
            completion(userInfo, error)
        }
    }
    
    func retrieveUserImage(withAuthorization authorization: GTMAppAuthFetcherAuthorization?, andUserInfo userInfo: GoogleUserInfo, withCompletion completion: @escaping (UIImage?)->Void) {
        fetcherService.authorizer = authorization
        
        let fetcher = fetcherService.fetcher(withURLString: userInfo.pictureURLString)
        fetcher.beginFetch { data, _ in
            guard let data = data else { completion(nil); return }
            let image = UIImage(data: data)
            completion(image)
        }
    }
}
