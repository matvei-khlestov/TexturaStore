//
//  EmptyStateView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

struct EmptyStateView: View {
    
    let text: String
    let horizontalPadding: CGFloat
    
    init(
        text: String,
        horizontalPadding: CGFloat = 24
    ) {
        self.text = text
        self.horizontalPadding = horizontalPadding
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, horizontalPadding)
            
            Spacer()
        }
    }
}
