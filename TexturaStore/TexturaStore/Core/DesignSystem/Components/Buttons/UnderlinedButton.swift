//
//  UnderlinedButton.swift
//  TexturaStore
//
//  Created by Matvei Khlestov on 02.02.2026.
//

import SwiftUI

/// Компонент `UnderlinedButton`.
///
/// Отвечает за:
/// - отображение текста в виде ссылки с подчёркиванием;
/// - возможность настройки шрифта;
/// - адаптацию под разное горизонтальное выравнивание.
///
/// Реализация:
/// - SwiftUI `Button`;
/// - `AttributedString` для подчёркивания (iOS 15+);
/// - поддержка переноса строк;
/// - используется `Color.brandPrimary`.
struct UnderlinedButton: View {

    // MARK: - Metrics

    private enum Metrics {
        enum Fonts {
            static let underline: Font = .system(size: 16)
        }
    }

    // MARK: - State

    @Binding private var text: String
    private let font: Font
    private let alignment: HorizontalAlignment
    private let action: () -> Void

    // MARK: - Init

    init(
        text: Binding<String>,
        font: Font = Metrics.Fonts.underline,
        alignment: HorizontalAlignment = .leading,
        action: @escaping () -> Void
    ) {
        self._text = text
        self.font = font
        self.alignment = alignment
        self.action = action
    }

    init(
        text: String,
        font: Font = Metrics.Fonts.underline,
        alignment: HorizontalAlignment = .leading,
        action: @escaping () -> Void
    ) {
        self._text = .constant(text)
        self.font = font
        self.alignment = alignment
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: alignment, spacing: 0) {
            Button(action: action) {
                Text(attributedText)
                    .font(font)
                    .multilineTextAlignment(textAlignment(for: alignment))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Attributed text

    private var attributedText: AttributedString {
        var attributed = AttributedString(text)
        attributed.foregroundColor = Color.brandPrimary
        attributed.underlineStyle = .single
        return attributed
    }

    // MARK: - Helpers

    private func textAlignment(for alignment: HorizontalAlignment) -> TextAlignment {
        switch alignment {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        default:
            return .center
        }
    }
}
