//
//  FavoritesRowView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 22.02.2026.
//

import SwiftUI

struct FavoritesRowView: View {
    
    let item: FavoriteItem
    let isInCart: Bool
    let priceText: String
    let onToggleCart: () -> Void
    
    private enum Metrics {
        static let imageHeight: CGFloat = 106
        
        static let buttonFontSize: CGFloat = 14
        static let buttonHPadding: CGFloat = 12
        static let buttonVPadding: CGFloat = 8
        static let inCartBgOpacity: CGFloat = 0.18
    }
    
    var body: some View {
        ProductRowContainerView(
            imageURL: item.imageURL,
            imageHeight: Metrics.imageHeight,
            brandName: item.brandName,
            title: item.title,
            priceText: priceText
        ) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onToggleCart()
            } label: {
                Text(isInCart ? L10n.Favorites.Cart.`in` : L10n.Favorites.Cart.add)
                    .font(.system(size: Metrics.buttonFontSize, weight: .semibold))
                    .padding(.horizontal, Metrics.buttonHPadding)
                    .padding(.vertical, Metrics.buttonVPadding)
                    .foregroundStyle(isInCart ? Color(uiColor: .brand) : .white)
                    .background(
                        Capsule()
                            .fill(
                                isInCart
                                ? Color(uiColor: .brand).opacity(Metrics.inCartBgOpacity)
                                : Color(uiColor: .brand)
                            )
                    )
            }
            .buttonStyle(.borderless)
        }
    }
}
