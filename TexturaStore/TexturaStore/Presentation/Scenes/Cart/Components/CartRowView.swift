//
//  CartRowView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

struct CartRowView: View {
    
    let item: CartItem
    let priceText: String
    
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    
    private enum Metrics {
        static let imageHeight: CGFloat = 105
        
        static let qtyHeight: CGFloat = 32
        static let qtyWidth: CGFloat = 100
        static let qtyCornerRadius: CGFloat = 16
        
        static let qtyIconSize: CGFloat = 14
        static let qtyButtonPaddingV: CGFloat = 6
        static let qtyButtonPaddingH: CGFloat = 10
    }
    
    var body: some View {
        ProductRowContainerView(
            imageURL: item.imageURL,
            imageHeight: Metrics.imageHeight,
            brandName: item.brandName,
            title: item.title,
            priceText: priceText
        ) {
            quantityCapsule
        }
        .contentShape(Rectangle())
    }
    
    private var quantityCapsule: some View {
        HStack(spacing: 0) {
            Button {
                guard item.quantity > 1 else { return }
                onDecrease()
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: Metrics.qtyIconSize, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .brand))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, Metrics.qtyButtonPaddingV)
                    .padding(.leading, Metrics.qtyButtonPaddingH)
            }
            .disabled(item.quantity <= 1)
            .buttonStyle(.plain)
            
            Text("\(max(1, item.quantity))")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(minWidth: 32)
                .padding(.horizontal, 6)
            
            Button {
                onIncrease()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: Metrics.qtyIconSize, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .brand))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, Metrics.qtyButtonPaddingV)
                    .padding(.trailing, Metrics.qtyButtonPaddingH)
            }
            .buttonStyle(.plain)
        }
        .frame(width: Metrics.qtyWidth, height: Metrics.qtyHeight)
        .background(
            RoundedRectangle(cornerRadius: Metrics.qtyCornerRadius)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}
