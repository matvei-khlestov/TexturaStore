//
//  OrderItemRow.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI
import Kingfisher

/// Строка `OrderItemRow` для экранов истории и деталей заказа.
///
/// Основные задачи:
/// - Показывает товар в заказе: картинка, бренд, название, цена, количество;
/// - Отображает сопутствующие данные заказа: адрес, дата создания, способ оплаты, статус (бейдж);
/// - Загружает изображение товара по URL.
///
/// Особенности:
/// - Адаптивная вёрстка на SwiftUI-стеках;
/// - View не содержит логики локализации названия товара и получает готовый `productTitle`;
/// - Отдельный тонкий разделитель с возможностью скрытия (`showsSeparator`).
struct OrderItemRow: View {
    
    // MARK: - Data
    
    let item: OrderItem
    let order: OrderEntity
    let productTitle: String
    let priceText: String
    let showsSeparator: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Metrics.Spacing.horizontal) {
                productImage
                
                VStack(alignment: .leading, spacing: Metrics.Spacing.vertical) {
                    Text(item.product.brandId)
                        .font(Font(Metrics.Fonts.brand))
                        .foregroundStyle(Color(uiColor: Colors.category))
                    
                    Text(productTitle)
                        .font(Font(Metrics.Fonts.title))
                        .foregroundStyle(Color(uiColor: Colors.title))
                        .multilineTextAlignment(.leading)
                    
                    Text(priceText)
                        .font(Font(Metrics.Fonts.price))
                        .foregroundStyle(Color(uiColor: Colors.price))
                    
                    Text(quantityText)
                        .font(Font(Metrics.Fonts.qty))
                        .foregroundStyle(Color(uiColor: Colors.qty))
                    
                    VStack(alignment: .leading, spacing: Metrics.Spacing.meta) {
                        VStack(alignment: .leading, spacing: Metrics.Spacing.metaInner) {
                            Text(L10n.Orders.Item.addressPrefix + order.receiveAddress)
                                .font(Font(Metrics.Fonts.meta))
                                .foregroundStyle(Color(uiColor: Colors.meta))
                                .multilineTextAlignment(.leading)
                            
                            Text(L10n.Orders.Item.datePrefix + formattedDate(order.createdAt))
                                .font(Font(Metrics.Fonts.meta))
                                .foregroundStyle(Color(uiColor: Colors.meta))
                                .multilineTextAlignment(.leading)
                            
                            Text(L10n.Orders.Item.paymentPrefix + order.paymentMethod)
                                .font(Font(Metrics.Fonts.meta))
                                .foregroundStyle(Color(uiColor: Colors.meta))
                        }
                        
                        StatusBadgeView(
                            text: order.status.badgeText,
                            color: statusColor(order.status)
                        )
                    }
                    .padding(.top, Metrics.Spacing.meta)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.top, Metrics.Insets.content.top)
            .padding(.horizontal, Metrics.Insets.content.leading)
            .padding(.bottom, Metrics.Insets.content.bottom)
            
            if showsSeparator {
                Rectangle()
                    .fill(Color(uiColor: .separator))
                    .frame(height: Metrics.Separator.height)
                    .padding(.leading, Metrics.Separator.leadingInset)
                    .padding(.trailing, Metrics.Separator.trailingInset)
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Subviews

private extension OrderItemRow {
    
    @ViewBuilder
    var productImage: some View {
        if let url = URL(string: item.product.imageURL) {
            KFImage(url)
                .placeholder {
                    Rectangle()
                        .fill(Color(uiColor: .secondarySystemBackground))
                }
                .cancelOnDisappear(true)
                .fade(duration: 0.2)
                .resizable()
                .scaledToFill()
                .frame(
                    width: Metrics.Sizes.thumbSide,
                    height: Metrics.Sizes.thumbSide
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: Metrics.Corners.thumb,
                        style: .continuous
                    )
                )
        } else {
            Rectangle()
                .fill(Color(uiColor: .secondarySystemBackground))
                .frame(
                    width: Metrics.Sizes.thumbSide,
                    height: Metrics.Sizes.thumbSide
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: Metrics.Corners.thumb,
                        style: .continuous
                    )
                )
        }
    }
}

// MARK: - Helpers

private extension OrderItemRow {
    
    var quantityText: String {
        "x\(item.quantity)"
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func statusColor(_ status: OrderStatus) -> UIColor {
        switch status {
        case .assembling:
            return .systemOrange
        case .ready:
            return .systemBlue
        case .delivering:
            return .systemTeal
        case .delivered:
            return .systemGreen
        case .cancelled:
            return .systemRed
        }
    }
}

// MARK: - Metrics

private extension OrderItemRow {
    
    enum Metrics {
        enum Insets {
            static let content = NSDirectionalEdgeInsets(
                top: 12,
                leading: 16,
                bottom: 12,
                trailing: 16
            )
        }
        
        enum Spacing {
            static let horizontal: CGFloat = 8
            static let vertical: CGFloat = 6
            static let meta: CGFloat = 8
            static let metaInner: CGFloat = 4
        }
        
        enum Sizes {
            static let thumbSide: CGFloat = 110
        }
        
        enum Corners {
            static let thumb: CGFloat = 12
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let brand: UIFont = .systemFont(ofSize: 12, weight: .regular)
            static let price: UIFont = .systemFont(ofSize: 18, weight: .bold)
            static let qty: UIFont = .systemFont(ofSize: 15, weight: .medium)
            static let meta: UIFont = .systemFont(ofSize: 14, weight: .regular)
        }
        
        enum Separator {
            static let height: CGFloat = 0.5
            static let leadingInset: CGFloat = 16
            static let trailingInset: CGFloat = 16
        }
    }
}

// MARK: - Colors

private extension OrderItemRow {
    
    enum Colors {
        static let title: UIColor = .label
        static let category: UIColor = .secondaryLabel
        static let price: UIColor = .brand
        static let qty: UIColor = .secondaryLabel
        static let meta: UIColor = .secondaryLabel
    }
}
