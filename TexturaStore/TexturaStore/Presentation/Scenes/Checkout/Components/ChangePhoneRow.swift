//
//  ChangePhoneRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

struct ChangePhoneRow: View {
    
    let phone: String?
    let placeholder: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: CheckoutView.Symbols.phone)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: CheckoutView.Metrics.Sizes.icon,
                        height: CheckoutView.Metrics.Sizes.icon
                    )
                    .foregroundStyle(Color(uiColor: .brand))
                
                Text(displayText)
                    .font(Font(CheckoutView.Metrics.Fonts.phone))
                    .foregroundStyle(displayColor)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
            
            Rectangle()
                .fill(Color(uiColor: .separator))
                .frame(height: CheckoutView.Metrics.Sizes.separatorHeight)
                .padding(.leading, 16)
        }
    }
    
    private var displayText: String {
        if let phone, !phone.isEmpty {
            return phone
        }
        return placeholder
    }
    
    private var displayColor: Color {
        if let phone, !phone.isEmpty {
            return Color(uiColor: .label)
        }
        return Color(uiColor: .secondaryLabel)
    }
}
