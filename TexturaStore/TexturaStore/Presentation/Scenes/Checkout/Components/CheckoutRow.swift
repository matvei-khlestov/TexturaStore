//
//  CheckoutRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI
import Kingfisher

struct CheckoutRow: View {
    
    let item: CartItem
    let priceText: String
    let showsSeparator: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                productImage
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.brandName)
                        .font(Font(CheckoutView.Metrics.Fonts.checkoutBrand))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    
                    Text(item.title)
                        .font(Font(CheckoutView.Metrics.Fonts.checkoutTitle))
                        .foregroundStyle(Color(uiColor: .label))
                        .lineLimit(2)
                    
                    Text(priceText)
                        .font(Font(CheckoutView.Metrics.Fonts.checkoutPrice))
                        .foregroundStyle(Color(uiColor: .brand))
                    
                    Text("x\(item.quantity)")
                        .font(Font(CheckoutView.Metrics.Fonts.checkoutQuantity))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                
                Spacer(minLength: 0)
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            if showsSeparator {
                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(height: CheckoutView.Metrics.Sizes.separatorHeight)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    @ViewBuilder
    private var productImage: some View {
        if let urlString = item.imageURL, let url = URL(string: urlString) {
            KFImage(url)
                .placeholder {
                    RoundedRectangle(
                        cornerRadius: CheckoutView.Metrics.Corners.checkoutThumb,
                        style: .continuous
                    )
                    .fill(Color(uiColor: .secondarySystemBackground))
                }
                .fade(duration: 0.2)
                .resizable()
                .scaledToFill()
                .frame(
                    width: CheckoutView.Metrics.Sizes.checkoutThumb,
                    height: CheckoutView.Metrics.Sizes.checkoutThumb
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: CheckoutView.Metrics.Corners.checkoutThumb,
                        style: .continuous
                    )
                )
        } else {
            RoundedRectangle(
                cornerRadius: CheckoutView.Metrics.Corners.checkoutThumb,
                style: .continuous
            )
            .fill(Color(uiColor: .secondarySystemBackground))
            .frame(
                width: CheckoutView.Metrics.Sizes.checkoutThumb,
                height: CheckoutView.Metrics.Sizes.checkoutThumb
            )
        }
    }
}
