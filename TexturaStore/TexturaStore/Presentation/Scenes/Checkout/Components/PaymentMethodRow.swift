//
//  PaymentMethodRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

struct PaymentMethodRow: View {
    
    let title: String
    let method: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Font(CheckoutView.Metrics.Fonts.paymentTitle))
                .foregroundStyle(Color(uiColor: .label))
            
            Text(method)
                .font(Font(CheckoutView.Metrics.Fonts.paymentMethod))
                .foregroundStyle(Color(uiColor: .label))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(uiColor: .secondarySystemBackground))
                .overlay(
                    RoundedRectangle(
                        cornerRadius: CheckoutView.Metrics.Corners.pill,
                        style: .continuous
                    )
                    .stroke(Color(uiColor: .brand), lineWidth: 1.2)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: CheckoutView.Metrics.Corners.pill,
                        style: .continuous
                    )
                )
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 16)
    }
}
