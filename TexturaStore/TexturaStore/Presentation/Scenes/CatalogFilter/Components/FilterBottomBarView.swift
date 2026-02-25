//
//  FilterBottomBarView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 24.02.2026.
//

import SwiftUI

/// SwiftUI-компонент нижней панели фильтра (аналог `FilterBottomBar` из UIKit).
///
/// Отвечает за:
/// - показ строки с количеством найденных товаров;
/// - кнопку применения фильтров;
/// - тень и скругление верхней панели.
///
/// Публичный API:
/// - `count` — количество найденных товаров;
/// - `hasActiveFilters` — флаг, что фильтры установлены;
/// - `onApply` — колбэк на нажатие кнопки.
struct FilterBottomBarView: View {
    
    // MARK: - Props
    
    let count: Int
    let hasActiveFilters: Bool
    let onApply: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Metrics.Spacing.stack) {
                
                Text(titleText)
                    .font(.system(size: Metrics.Fonts.titleSize, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Metrics.Insets.content)
                    .padding(.horizontal, Metrics.Insets.content)
                
                Button(action: onApply) {
                    Text(buttonText)
                        .font(.system(size: Metrics.Fonts.buttonSize, weight: .semibold))
                        .foregroundStyle(Color(uiColor: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: Metrics.Sizes.buttonHeight)
                        .background(Capsule().fill(Color(uiColor: .brand)))
                        .padding(.horizontal, Metrics.Insets.content)
                }
                .buttonStyle(.plain)
                .padding(.bottom, Metrics.Insets.content)
            }
            .background(
                RoundedRectangle(cornerRadius: Metrics.Sizes.corner, style: .continuous)
                    .fill(Color(uiColor: .clear))
            )
        }
        .shadow(
            color: Color.black.opacity(Metrics.Sizes.shadowOpacity),
            radius: Metrics.Sizes.shadowRadius,
            x: 0,
            y: Metrics.Sizes.shadowYOffset
        )
        .accessibilityElement(children: .contain)
    }
}

// MARK: - UI Text

private extension FilterBottomBarView {
    
    var titleText: String {
        if hasActiveFilters {
            return L10n.Filter.BottomBar.Title.found(count)
        } else {
            return L10n.Filter.BottomBar.Title.empty
        }
    }
    
    var buttonText: String {
        if hasActiveFilters {
            return L10n.Filter.BottomBar.Button.showCount(count)
        } else {
            return L10n.Filter.BottomBar.Button.showAll
        }
    }
}

// MARK: - Metrics

private extension FilterBottomBarView {
    
    enum Metrics {
        enum Insets {
            static let content: CGFloat = 16
        }
        
        enum Sizes {
            static let corner: CGFloat = 20
            static let buttonHeight: CGFloat = 52
            
            static let shadowRadius: CGFloat = 12
            static let shadowOpacity: CGFloat = 0.12
            static let shadowYOffset: CGFloat = -2
        }
        
        enum Fonts {
            static let titleSize: CGFloat = 17
            static let buttonSize: CGFloat = 17
        }
        
        enum Spacing {
            static let stack: CGFloat = 12
        }
    }
}
