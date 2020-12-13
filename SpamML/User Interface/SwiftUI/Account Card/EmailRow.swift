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
            
            // Timestamp
            Text(email.timestampString)
                .font(Font.system(size: 12, weight: .bold, design: .default))
                .lineLimit(1)
                .foregroundColor(Color(UIColor.white.withAlphaComponent(0.9)))

            // Header
            HStack {
                // Sender Fields
                Text(email.from.displayName ?? "")
                    .font(Font.system(size: 17, weight: .bold, design: .default))
                    .lineLimit(1)
                    .foregroundColor(Color(UIColor.white))
                
                Text("<\(email.from.emailAddress ?? "")>")
                    .font(Font.system(size: 12, weight: .bold, design: .default))
                    .lineLimit(1)
                    .foregroundColor(Color(UIColor.white))
            }
            .padding(.bottom, 2)
            
            Text(email.subject)
                .font(Font.system(size: 15, weight: .semibold, design: .default))
                .lineLimit(1)
                .foregroundColor(.white)
            
            Text(email.body)
                .font(Font.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(Color(UIColor.white.withAlphaComponent(0.9)))
                .lineLimit(2)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct EmailRow_Previews: PreviewProvider {
    static var previews: some View {
        let testEmail = Email.testInstance(subject: "Buy the new iPhone 12 Pro Max!", body: "Available now, starting at $1099! Order yours today before it's too late! This offer will only last for a short period of time!", id: "1")
        EmailRow(email: testEmail)
            .background(Color.blue)
    }
}
