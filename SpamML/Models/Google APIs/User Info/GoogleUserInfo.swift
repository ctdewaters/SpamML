//
//  GoogleUserInfo.swift
//  SpamML
//
//  Created by Collin DeWaters on 10/25/20.
//

import Foundation

struct GoogleUserInfo: Codable {
    let name: String
    let pictureURLString: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case name, pictureURLString = "picture", email
    }
}
