//
//  SpamMLUserDefaults.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/13/20.
//

import Foundation

struct SpamMLUserDefaults {
    private static let standard = UserDefaults.standard
    
    static var onboardingComplete: Bool {
        set {
            standard.setValue(newValue, forKey: "onboardingComplete")
        }
        get {
            standard.bool(forKey: "onboardingComplete")
        }
    }
}
