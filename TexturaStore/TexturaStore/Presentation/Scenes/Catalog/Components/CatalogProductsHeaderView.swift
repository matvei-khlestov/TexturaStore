//
//  CatalogProductsHeaderView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 23.02.2026.
//

import SwiftUI

struct CatalogProductsHeaderView: View {
    
    let count: Int
    let onFilterTap: () -> Void
    
    private enum Metrics {
        static let titleSize: CGFloat = 22
        static let filterSize: CGFloat = 16
        static let badgeSize: CGFloat = 12
        static let iconPointSize: CGFloat = 20
        
        static let hSpacing: CGFloat = 8
        static let iconToLabel: CGFloat = 6
        static let labelToBadge: CGFloat = 6
        
        static let badgeHeight: CGFloat = 18
        static let badgeHorizontalPadding: CGFloat = 6
    }
    
    private enum Symbols {
        static let filterIconName = "line.3.horizontal.decrease"
    }
    
    var body: some View {
        HStack(spacing: Metrics.hSpacing) {
            Text(L10n.Catalog.Products.title)
                .font(.system(size: Metrics.titleSize, weight: .bold))
                .foregroundStyle(Color(uiColor: .label))
            
            Spacer(minLength: 0)
            
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onFilterTap()
            }) {
                HStack(spacing: 0) {
                    Image(systemName: Symbols.filterIconName)
                        .font(.system(size: Metrics.iconPointSize, weight: .regular))
                        .foregroundStyle(Color(uiColor: .brand))
                    
                    Text(L10n.Catalog.Filters.title)
                        .font(.system(size: Metrics.filterSize, weight: .medium))
                        .foregroundStyle(Color(uiColor: .label))
                        .padding(.leading, Metrics.iconToLabel)
                    
                    if count > 0 {
                        Text("\(count)")
                            .font(.system(size: Metrics.badgeSize, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, Metrics.badgeHorizontalPadding)
                            .frame(height: Metrics.badgeHeight)
                            .background(
                                Capsule()
                                    .fill(Color(uiColor: .systemRed))
                            )
                            .fixedSize()
                            .padding(.leading, Metrics.labelToBadge)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Catalog.Filters.title)
        }
    }
}
