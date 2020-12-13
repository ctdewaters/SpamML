//
//  EmailRow.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/13/20.
//

import SwiftUI

struct EmailRow: View {
    let email: Email
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(email.timestampString)
                .font(.caption)
                .foregroundColor(Color(UIColor.white.withAlphaComponent(0.9)))
            Text(email.subject)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.white)
            Text(email.body)
                .font(.subheadline)
                .foregroundColor(Color(UIColor.white.withAlphaComponent(0.9)))
                .lineLimit(2)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct EmailRow_Previews: PreviewProvider {
    static var previews: some View {
        let testEmail = Email(subject: "Buy the new iPhone 12 Pro Max!", body: "Available now, starting at $1099! Order yours today before it's too late! This offer will only last for a short period of time!", timestamp: Date())
        EmailRow(email: testEmail)
            .background(Color.blue)
    }
}
