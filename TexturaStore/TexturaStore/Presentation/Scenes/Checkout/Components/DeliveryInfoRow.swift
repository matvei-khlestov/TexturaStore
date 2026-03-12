//
//  DeliveryInfoRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

struct DeliveryInfoRow: View {
    
    let when: String
    let cost: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Checkout.Delivery.Store.title)
                .font(Font(CheckoutView.Metrics.Fonts.deliveryTitle))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            Text(when)
                .font(Font(CheckoutView.Metrics.Fonts.deliveryWhen))
                .foregroundStyle(Color(uiColor: .label))
            
            Text(cost)
                .font(Font(CheckoutView.Metrics.Fonts.deliveryCost))
                .foregroundStyle(Color.green)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 16)
    }
}
