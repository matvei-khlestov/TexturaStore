//
//  OrderCommentRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

struct OrderCommentRow: View {
    
    let comment: String?
    let placeholder: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: CheckoutView.Symbols.comment)
                .resizable()
                .scaledToFit()
                .frame(
                    width: CheckoutView.Metrics.Sizes.icon,
                    height: CheckoutView.Metrics.Sizes.icon
                )
                .foregroundStyle(Color(uiColor: .brand))
            
            Text(displayText)
                .font(Font(CheckoutView.Metrics.Fonts.comment))
                .foregroundStyle(displayColor)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 16)
    }
    
    private var displayText: String {
        let trimmed = comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmed, !trimmed.isEmpty {
            return trimmed
        }
        return placeholder
    }
    
    private var displayColor: Color {
        let trimmed = comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let trimmed, !trimmed.isEmpty {
            return Color(uiColor: .label)
        }
        return Color(uiColor: .secondaryLabel)
    }
}
