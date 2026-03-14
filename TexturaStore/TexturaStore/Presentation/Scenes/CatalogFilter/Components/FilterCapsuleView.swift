//
//  FilterCapsuleView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

/// Универсальная капсула фильтра.
/// Для категорий/брендов `leading` — изображение,
/// для цветов — `ColorDotView(hex:)`.
struct FilterCapsuleView<Leading: View>: View {
    
    // MARK: - Props
    
    let title: String
    let isSelected: Bool
    let leading: () -> Leading
    let onTap: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: FilterCapsuleViewMetrics.Spacing.inner) {
                leading()
                
                Text(title)
                    .font(.system(size: FilterCapsuleViewMetrics.Fonts.titleSize, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(1)
            }
            .padding(.horizontal, FilterCapsuleViewMetrics.Insets.horizontal)
            .padding(.vertical, FilterCapsuleViewMetrics.Insets.vertical)
            .background(
                Capsule().fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .overlay(
                Capsule().stroke(
                    isSelected ? Color(uiColor: .brand) : Color(uiColor: .separator),
                    lineWidth: isSelected ? FilterCapsuleViewMetrics.Stroke.selected : FilterCapsuleViewMetrics.Stroke.normal
                )
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Metrics

private enum FilterCapsuleViewMetrics {
    enum Insets {
        static let horizontal: CGFloat = 12
        static let vertical: CGFloat = 10
    }
    enum Spacing {
        static let inner: CGFloat = 8
    }
    enum Fonts {
        static let titleSize: CGFloat = 14
    }
    enum Stroke {
        static let normal: CGFloat = 1
        static let selected: CGFloat = 2
    }
}
