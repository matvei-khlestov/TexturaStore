//
//  PickupAddressRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

struct PickupAddressRow: View {
    
    let address: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: CheckoutView.Symbols.storefront)
                .resizable()
                .scaledToFit()
                .frame(
                    width: CheckoutView.Metrics.Sizes.pickupIcon,
                    height: CheckoutView.Metrics.Sizes.pickupIcon
                )
                .foregroundStyle(Color(uiColor: .brand))
            
            Text(address)
                .font(Font(CheckoutView.Metrics.Fonts.address))
                .foregroundStyle(Color(uiColor: .label))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 16)
    }
}
