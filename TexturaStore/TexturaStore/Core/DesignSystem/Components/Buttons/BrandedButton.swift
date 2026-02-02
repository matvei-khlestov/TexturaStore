//
//  BrandedButton.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import SwiftUI

/// Компонент `BrandedButton`.
///
/// Отвечает за:
/// - единый бренд-стиль кнопок в приложении;
/// - управление состояниями (normal/disabled);
/// - вариант с тенью для акцентных CTA;
/// - вариант submit с особыми disabled-цветами;
/// - вариант logout с иконкой.
///
/// Публичный API:
/// - `init(style:title:isEnabled:action:)` — инициализация с нужным стилем;
/// - `Style` — перечисление вариантов оформления.
struct BrandedButton: View {

    enum Style: Equatable {
        /// Фирменная кнопка без теней
        case primary
        /// Фирменная кнопка с тенью (для Checkout, Cart и т.п.)
        case primaryWithShadow
        /// Сабмит-кнопка с особым disabled-состоянием
        case submit
        /// Кнопка выхода (с иконкой и кастомными инсетами)
        case logout(icon: String)
    }

    // MARK: - Metrics

    private enum Metrics {
        enum Sizes {
            static let height: CGFloat = 50
            static let cornerRadius: CGFloat = 16
        }

        enum Insets {
            static let content = EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            static let logoutContent = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        }

        enum Shadows {
            static let opacity: Double = 0.5
            static let radius: CGFloat = 8
            static let offsetX: CGFloat = 0
            static let offsetY: CGFloat = 4
        }

        enum Image {
            static let padding: CGFloat = 10
        }

        enum Fonts {
            static let title = Font.system(size: 16, weight: .semibold)
        }
    }

    // MARK: - Colors

    private enum Colors {
        static let normalBG = Color("brandColor")
        static let normalFG = Color.white
        static let disabledBG = Color("brandColor").opacity(0.65)
        static let disabledFG = Color.white.opacity(0.9)
    }

    // MARK: - Public API

    private let style: Style
    private let title: String
    private let isEnabled: Bool
    private let action: () -> Void

    // MARK: - Init

    init(
        style: Style,
        title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.style = style
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            label
                .frame(maxWidth: .infinity)
                .padding(contentInsets)
                .frame(height: Metrics.Sizes.height)
        }
        .buttonStyle(.plain)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.Sizes.cornerRadius, style: .continuous))
        .disabled(!isEnabled)
        .shadow(
            color: shadowColor,
            radius: shadowRadius,
            x: shadowX,
            y: shadowY
        )
        .accessibilityLabel(Text(title))
    }

    // MARK: - Label

    @ViewBuilder
    private var label: some View {
        switch style {
        case .logout(let iconName):
            HStack(spacing: Metrics.Image.padding) {
                Image(systemName: iconName)
                    .foregroundStyle(foregroundColor)
                Text(title)
                    .foregroundStyle(foregroundColor)
                    .font(Metrics.Fonts.title)
                    .lineLimit(1)
            }

        case .primary, .primaryWithShadow, .submit:
            Text(title)
                .foregroundStyle(foregroundColor)
                .font(Metrics.Fonts.title)
                .lineLimit(1)
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: Metrics.Sizes.cornerRadius, style: .continuous)
            .fill(backgroundColor)
    }

    // MARK: - Computed style

    private var backgroundColor: Color {
        switch style {
        case .submit:
            return isEnabled ? Colors.normalBG : Colors.disabledBG
        case .primary, .primaryWithShadow, .logout:
            return Colors.normalBG
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .submit:
            return isEnabled ? Colors.normalFG : Colors.disabledFG
        case .primary, .primaryWithShadow, .logout:
            return Colors.normalFG
        }
    }

    private var contentInsets: EdgeInsets {
        switch style {
        case .logout:
            return Metrics.Insets.logoutContent
        case .primary, .primaryWithShadow, .submit:
            return Metrics.Insets.content
        }
    }

    // MARK: - Shadow

    private var shadowColor: Color {
        switch style {
        case .primaryWithShadow:
            return .black.opacity(Metrics.Shadows.opacity)
        default:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .primaryWithShadow:
            return Metrics.Shadows.radius
        default:
            return 0
        }
    }

    private var shadowX: CGFloat {
        switch style {
        case .primaryWithShadow:
            return Metrics.Shadows.offsetX
        default:
            return 0
        }
    }

    private var shadowY: CGFloat {
        switch style {
        case .primaryWithShadow:
            return Metrics.Shadows.offsetY
        default:
            return 0
        }
    }
}
