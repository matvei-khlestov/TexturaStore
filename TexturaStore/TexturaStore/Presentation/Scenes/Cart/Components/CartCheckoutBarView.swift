//
//  CartCheckoutBarView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

struct CartCheckoutBarView: View {
    
    let onCheckout: () -> Void
    
    let horizontalPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            Button {
                onCheckout()
            } label: {
                Text(L10n.Cart.Checkout.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(uiColor: .brand))
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .background(.ultraThinMaterial)
        }
    }
}
