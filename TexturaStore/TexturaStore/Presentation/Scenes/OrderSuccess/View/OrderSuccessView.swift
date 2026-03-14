//
//  OrderSuccessView.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 12.03.2026.
//

import SwiftUI

/// View `OrderSuccessView` для экрана успешного оформления.
///
/// Отвечает за:
/// - показ состояния успеха: большой иконки, заголовка и подзаголовка;
/// - отображение кнопки возврата в каталог и обработку её нажатия;
/// - минимальную навигацию (скрытие navigation bar на экране).
///
/// Взаимодействует с:
/// - колбэком `onViewCatalog` для маршрутизации назад в каталог.
///
/// Особенности:
/// - чистый UI без бизнес-логики;
/// - верстка через вертикальные `VStack` с аккуратными отступами;
/// - лёгкая тактильная отдача при нажатии кнопки.
struct OrderSuccessView: View {
    
    // MARK: - Callbacks
    
    var onViewCatalog: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Spacing {
            static let stack: CGFloat = 24
            static let textStack: CGFloat = 8
        }
        
        enum Sizes {
            static let iconSize: CGFloat = 96
            static let buttonMinHeight: CGFloat = 44
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 28, weight: .bold)
            static let subtitle: UIFont = .systemFont(ofSize: 16, weight: .regular)
            static let button: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let title: Color = .white
        static let subtitle: Color = Color.white.opacity(0.8)
        static let buttonBackground: Color = Color.white.opacity(0.9)
        static let buttonForeground: Color = Color(uiColor: .brand)
        static let background: Color = Color(uiColor: .brand)
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title = "Заказ успешно оформлен"
        static let subtitle = "Спасибо, что выбрали нас! Продолжайте шопинг."
        static let button = "Вернуться в магазин"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let success = "checkmark.circle.fill"
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Metrics.Spacing.stack) {
                Image(systemName: Symbols.success)
                    .font(.system(size: Metrics.Sizes.iconSize, weight: .semibold))
                    .foregroundStyle(Color.white)
                
                VStack(spacing: Metrics.Spacing.textStack) {
                    Text(Texts.title)
                        .font(Font(Metrics.Fonts.title))
                        .foregroundStyle(Colors.title)
                        .multilineTextAlignment(.center)
                    
                    Text(Texts.subtitle)
                        .font(Font(Metrics.Fonts.subtitle))
                        .foregroundStyle(Colors.subtitle)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: viewOrderTapped) {
                    Text(Texts.button)
                        .font(Font(Metrics.Fonts.button))
                        .foregroundStyle(Colors.buttonForeground)
                        .frame(minHeight: Metrics.Sizes.buttonMinHeight)
                        .padding(.horizontal, 20)
                        .background(Colors.buttonBackground)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Actions

private extension OrderSuccessView {
    
    func viewOrderTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onViewCatalog?()
    }
}
