//
//  ProductCardView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI
import Kingfisher

struct ProductCardView: View {
    
    let product: Product
    let title: String
    
    let isFavorite: Bool
    let isInCart: Bool
    let priceText: String
    
    let onToggleCart: (Bool) -> Void
    let onToggleFavorite: () -> Void
    
    private enum Metrics {
        enum Corners {
            static let card: CGFloat = 14
            static let image: CGFloat = 12
        }
        
        enum Shadow {
            static let opacity: CGFloat = 0.06
            static let radius: CGFloat = 8
            static let y: CGFloat = 4
        }
        
        enum Insets {
            static let imageH: CGFloat = 12
            static let imageTop: CGFloat = 12
            
            static let favoriteTop: CGFloat = 6
            static let favoriteTrailing: CGFloat = 6
            
            static let labelsH: CGFloat = 16
            static let addToCartLeading: CGFloat = 12
            static let addToCartBottom: CGFloat = 16
            
            static let cardHorizontal: CGFloat = 9
        }
        
        enum Fonts {
            static let priceSize: CGFloat = 18
            static let titleSize: CGFloat = 15
            static let brandSize: CGFloat = 13
            static let ratingSize: CGFloat = 13
            static let ratingIconSize: CGFloat = 12
        }
        
        enum Spacing {
            static let imageToBrand: CGFloat = 10
            static let titleToPrice: CGFloat = 6
            static let priceToRating: CGFloat = 6
        }
        
        enum FavoriteButton {
            static let pointSize: CGFloat = 17
            static let bgSide: CGFloat = 33
        }
    }
    
    private enum Symbols {
        static let heartFilled = "heart.fill"
        static let heart = "heart"
        static let starFilled = "star.fill"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ProductImage(urlString: product.imageURL)
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.Corners.image))
                    .padding(.top, Metrics.Insets.imageTop)
                    .padding(.horizontal, Metrics.Insets.imageH)
                
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    onToggleFavorite()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .frame(
                                width: Metrics.FavoriteButton.bgSide,
                                height: Metrics.FavoriteButton.bgSide
                            )
                        
                        Image(systemName: isFavorite ? Symbols.heartFilled : Symbols.heart)
                            .font(.system(size: Metrics.FavoriteButton.pointSize, weight: .semibold))
                            .foregroundStyle(
                                isFavorite
                                ? Color(uiColor: .systemRed)
                                : Color(uiColor: .label)
                            )
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, Metrics.Insets.imageTop + Metrics.Insets.favoriteTop)
                .padding(.trailing, Metrics.Insets.imageH + Metrics.Insets.favoriteTrailing)
                .accessibilityLabel(
                    isFavorite
                    ? L10n.Catalog.Product.Favorite.remove
                    : L10n.Catalog.Product.Favorite.add
                )
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(product.brandId)
                    .font(.system(size: Metrics.Fonts.brandSize, weight: .regular))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .lineLimit(1)
                    .padding(.top, Metrics.Spacing.imageToBrand)
                
                Text(title)
                    .font(.system(size: Metrics.Fonts.titleSize, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(2)
                    .padding(.top, 4)
                
                Text(priceText)
                    .font(.system(size: Metrics.Fonts.priceSize, weight: .bold))
                    .foregroundStyle(Color(uiColor: .brand))
                    .lineLimit(1)
                    .padding(.top, Metrics.Spacing.titleToPrice)
                
                HStack(spacing: 4) {
                    Image(systemName: Symbols.starFilled)
                        .font(.system(size: Metrics.Fonts.ratingIconSize, weight: .semibold))
                        .foregroundStyle(Color.yellow)
                    
                    Text(ratingText)
                        .font(.system(size: Metrics.Fonts.ratingSize, weight: .medium))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .lineLimit(1)
                }
                .padding(.top, Metrics.Spacing.priceToRating)
                
                HStack {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        onToggleCart(!isInCart)
                    }) {
                        Text(isInCart ? L10n.Catalog.Product.Cart.`in` : L10n.Catalog.Product.Cart.add)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .foregroundStyle(isInCart ? Color(uiColor: .brand) : .white)
                            .background(
                                Capsule()
                                    .fill(
                                        Color(uiColor: .brand)
                                            .opacity(isInCart ? 0.18 : 1.0)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer(minLength: 0)
                }
                .padding(.top, 8)
                .padding(.leading, Metrics.Insets.addToCartLeading - Metrics.Insets.labelsH)
                .padding(.bottom, Metrics.Insets.addToCartBottom)
            }
            .padding(.horizontal, Metrics.Insets.labelsH)
        }
        .background(
            RoundedRectangle(cornerRadius: Metrics.Corners.card)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(
                    color: Color.black.opacity(Metrics.Shadow.opacity),
                    radius: Metrics.Shadow.radius,
                    x: 0,
                    y: Metrics.Shadow.y
                )
        )
        .padding(.horizontal, Metrics.Insets.cardHorizontal)
    }
    
    private var ratingText: String {
        "\(formattedRating) (\(product.ratingCount))"
    }
    
    private var formattedRating: String {
        if product.ratingAvg.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", product.ratingAvg)
        } else {
            return String(format: "%.1f", product.ratingAvg)
        }
    }
}

struct ProductImage: View {
    
    let urlString: String
    
    var body: some View {
        let url = URL(string: urlString)
        
        KFImage(url)
            .placeholder { Color(uiColor: .secondarySystemBackground) }
            .cacheOriginalImage()
            .fade(duration: 0.15)
            .resizable()
            .scaledToFill()
            .clipped()
    }
}
