//
//  EmailViewModel.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/13/20.
//

import SwiftUI

struct EmailViewModel: Identifiable, Hashable {
    let subject: String
    let bodyPreview: String
    let body: Data?
    let timestamp: Date
    
    let id = UUID().uuidString
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var timestampString: String {
        EmailViewModel.timestampFormatter.string(from: timestamp)
    }
}
