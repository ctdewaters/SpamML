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
        
    private let redirectURI = "com.googleusercontent.apps.906281823650-r09686rj7oonfrh65lbcke4opah72ojs:/oauthredirect"
    private let clientID = "906281823650-r09686rj7oonfrh65lbcke4opah72ojs.apps.googleusercontent.com"
    private let issuer = "https://accounts.google.com"
    private let authKey = "googleauthkey_changethis"
    
    private let reachability: Reachability = { try! Reachability() }()
    
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private let fetcherService = GTMSessionFetcherService()
    
    // MARK: - Caches
    private let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Typealiases
    typealias AuthenticationCompletion = (GTMAppAuthFetcherAuthorization?)->Void
    
        
    // MARK: - Login Flow
    /// Presents the Google login flow modally, if this device is connected to the internet.
    /// - Parameters:
    ///   - presentingViewController: The view controller to present the Google Sign In flow on.
    ///   - completion: A callback supplied with the authentication object if successful.
    func performLoginIfRequired(withPresentingViewController presentingViewController: UIViewController, andCompletion completion: @escaping AuthenticationCompletion) {
        if reachability.connection != .unavailable {
            DispatchQueue.main.async {
                    self.performInitialAuthorization(withPresentingViewController: presentingViewController, andCompletion: completion)
                }
            }
        }
        
    private func performInitialAuthorization(withPresentingViewController presentingViewController: UIViewController, andCompletion completion: @escaping AuthenticationCompletion) {
        let issuerURL = URL(string: issuer)!
        let redirectURL = URL(string: redirectURI)!
        
        // Retrieve the Google configuration.
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuerURL) { [weak self] (config, error) in
            guard let sself = self, let config = config else { return }
                        
            // Create and run the auth request
            let request = OIDAuthorizationRequest(configuration: config,
                                                  clientId: sself.clientID,
                                                  scopes: [OIDScopeOpenID, OIDScopeProfile, OIDScopeEmail, "https://mail.google.com/"],
                                                  redirectURL: redirectURL,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
                        
            sself.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: presentingViewController) { [weak self] authState, error in
                
                var auth: GTMAppAuthFetcherAuthorization?
                if let authState = authState {
                    auth = GTMAppAuthFetcherAuthorization(authState: authState)
                }
                
                // Check for valid authorization.
                // This also saves the user info in the keychain if successful.
                self?.checkIfAuthorizationIsValid(auth) { [weak self] valid in
                    guard valid else { DispatchQueue.main.async { completion(nil) }; return }
                    
                    self?.save(authorization: auth)
                    DispatchQueue.main.async { completion(auth) }
                }
            }
        }
    }

    // MARK: - Authorization Validation
    private func checkIfAuthorizationIsValid(_ authorization: GTMAppAuthFetcherAuthorization?, withCompletion completion: ((Bool)->Void)?) {
        retrieveUserInfo(withAuthorization: authorization) { userInfo in
            completion?(userInfo != nil)
        }
    }
    
    // MARK: - Saving / Loading / Deleting Authorizations
    private func save(authorization: GTMAppAuthFetcherAuthorization?) {
        guard let auth = authorization, let key = auth.userID else { return }
        
        let accountKey = Keychain.AccountKey(key: key, source: .google)
        Keychain.shared.accountKeys.append(accountKey)
        GTMAppAuthFetcherAuthorization.save(auth, toKeychainForName: key)
    }
    
    private func load(authorizationWithKey key: String) -> GTMAppAuthFetcherAuthorization? {
        GTMAppAuthFetcherAuthorization(fromKeychainForName: key)
    }

    private func delete(authorization: GTMAppAuthFetcherAuthorization?) {
        guard let auth = authorization, let key = auth.userID else { return }
        Keychain.shared.accountKeys.removeAll { $0.keyString == key }
        GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: key)
    }
}

// MARK: - UserInfo
extension GoogleSignInService {
    func retrieveUserInfo(withAuthorization authorization: GTMAppAuthFetcherAuthorization?, withCompletion completion: @escaping (GoogleUserInfo?)->Void) {
        guard let auth = authorization else { completion(nil); return }
        
        // Check Keychain for stored `GoogleUserInfo` object.
        if let userInfo = auth.userInfo {
            completion(userInfo)
            return
        }
        
        fetcherService.authorizer = authorization
                
        let fetcher = fetcherService.fetcher(withURLString: "https://www.googleapis.com/oauth2/v3/userinfo")
        fetcher.beginFetch { data, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let userInfo = try? JSONDecoder().decode(GoogleUserInfo.self, from: data)
            
            // Save the user info object to the keychain with the authorization.
            auth.userInfo = userInfo
            
            completion(userInfo)
        }
    }
    
    func retrieveUserImage(withAuthorization authorization: GTMAppAuthFetcherAuthorization?, andUserInfo userInfo: GoogleUserInfo, withCompletion completion: @escaping (UIImage?)->Void) {
        guard let key = authorization?.userID else { completion(nil); return }
        
        if let image = imageCache.object(forKey: key as NSString) {
            completion(image)
            return
        }
        
        fetcherService.authorizer = authorization
        
        let fetcher = fetcherService.fetcher(withURLString: userInfo.pictureURLString)
        fetcher.beginFetch { data, _ in
            guard let data = data else { completion(nil); return }
            let image = UIImage(data: data)
            completion(image)
            
            if let image = image {
                self.imageCache.setObject(image, forKey: key as NSString)
            }
        }
    }
}
