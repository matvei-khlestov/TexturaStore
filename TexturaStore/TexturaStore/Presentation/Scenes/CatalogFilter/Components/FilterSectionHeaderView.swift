//
//  FilterSectionHeaderView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

/// Заголовок секции фильтра (например: «Категории», «Бренды», «Цвета», «Цена»).
struct FilterSectionHeaderView: View {
    
    // MARK: - Props
    
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(Metrics.Fonts.title)
                    .foregroundStyle(Color(uiColor: Metrics.Colors.title))
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Metrics.Insets.horizontal)
            .padding(.vertical, Metrics.Insets.vertical)
            
            Divider()
                .padding(.horizontal, Metrics.Insets.horizontal)
        }
        .background(Color(uiColor: Metrics.Colors.background))
    }
}

// MARK: - Metrics

private extension FilterSectionHeaderView {
    
    enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 12
            static let vertical: CGFloat = 6
        }
        
        enum Fonts {
            static let title: Font = .system(size: 17, weight: .semibold)
        }
        
        enum Colors {
            static let title: UIColor = .label
            static let background: UIColor = .systemGroupedBackground
        }
    }
}
