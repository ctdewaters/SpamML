//
//  EmailRow.swift
//  SpamML
//
//  Created by Collin DeWaters on 11/13/20.
//

import SwiftUI

struct EmailRow: View {
    let emailViewModel: EmailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(emailViewModel.timestampString)
                .font(.caption)
                .foregroundColor(Color(UIColor.white.withAlphaComponent(0.9)))
            Text(emailViewModel.subject)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(.white)
            Text(emailViewModel.bodyPreview)
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
        let testViewModel = EmailViewModel(subject: "Buy the new iPhone 12 Pro Max!", bodyPreview: "Available now, starting at $1099! Order yours today before it's too late! This offer will only last for a short period of time!", body: nil, timestamp: Date())
        EmailRow(emailViewModel: testViewModel)
            .background(Color.blue)
    }
}
